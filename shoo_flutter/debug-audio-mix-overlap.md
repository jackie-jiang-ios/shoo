# Debug Session: audio-mix-overlap
- **Status**: [OPEN]
- **Issue**: 详情页连续点击不同声音后，旧声音未停止，播放次数越多混音越多。
- **Debug Server**: http://10.5.43.91:7778/event
- **Log File**: .dbg/trae-debug-log-audio-mix-overlap.ndjson

## Reproduction Steps
1. 打开任意动物详情页。
2. 依次点击多个声音的“播放”，例如先狗叫、再枪声、再其他声音。
3. 实际结果：旧声音未停止，叠加成混音。
4. 期望结果：任意时刻只保留当前最新一次播放。

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | 同一个 `AudioController.play()` 被短时间重入，旧请求在异步初始化完成后仍开始播放 | High | Low | Confirmed |
| B | 详情页一次点击触发了多次 `play()` 调用 | Medium | Low | Inconclusive |
| C | 除 `AudioController` 外，还有其他播放入口也在创建 `AudioPlayer` | Medium | Medium | Rejected |
| D | `stop()` 执行时没有拿到所有底层播放器，导致旧播放器继续存在 | High | Low | Confirmed |

## Log Evidence
- 插桩点：
  - `B` `home_page:_playSound`：记录每次 UI 播放请求。
  - `A` `audio_controller:_startPlayback:beforeStop`：记录 `play()` 重入和切换请求。
  - `D` `audio_controller:_stopPlayers:*`：记录 `stop()` 之前/之后的追踪播放器数量。
  - `A` `audio_controller:_configurePlayer:staleAfterAsset`：记录旧请求在异步初始化后失效的情况。
  - `D` `audio_controller:_playSingle:afterPlay`：记录播放器真正开始播放的时刻。
  - `C` `audio_engine:play`：记录另一套混音引擎是否被调用。
- 用户提供的 iOS 原生日志中持续出现大量 `<<<< FigFilePlayer >>>> signalled err=-12864`。
- 该信号与“短时间反复创建底层文件播放器”一致，不像单个播放器的正常切轨。
- 代码审查确认旧实现使用 `List<AudioPlayer>`，并在 `await player.play()` 成功后才 `add` 到 `_players`，导致正在初始化的播放器不受 `stop()` 控制。

## Verification Conclusion
- 根因已确认：`AudioController` 旧实现会在详情页快速切换声音时反复创建新的 `AudioPlayer`，但 `stop()` 只能停掉已登记的播放器；尚未登记的播放器会在异步初始化完成后继续播放，造成混音层层累积。
- 已实施修复：将控制器收敛为“全局只维护一个底层 `AudioPlayer`”，切换声音时先销毁当前播放器，再创建新的；连续播放模式也复用同一个当前播放器引用，不再维护播放器列表。
