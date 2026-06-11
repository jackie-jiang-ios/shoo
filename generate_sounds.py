#!/usr/bin/env python3
"""
生成 Shoo 应用所需的所有声音文件。

每个声音通过程序化合成（频率调制、噪声叠加、包络控制等）来模拟对应效果。
生成 WAV 后使用 ffmpeg 转为 MP3。
"""

import wave
import struct
import math
import os
import subprocess
import random

SAMPLE_RATE = 44100
BASE_DIR_FLUTTER = "shoo_flutter/assets/sounds"
BASE_DIR_SHARED = "shared/sounds"

def ensure_dir(path):
    os.makedirs(path, exist_ok=True)

def write_wav(filename, samples, sample_rate=SAMPLE_RATE):
    """写入 16-bit mono WAV 文件"""
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        data = b''
        for s in samples:
            clamped = max(-32767, min(32767, int(s * 32767)))
            data += struct.pack('<h', clamped)
        wf.writeframes(data)

def wav_to_mp3(wav_path, mp3_path):
    """使用 ffmpeg 将 WAV 转为 MP3"""
    cmd = ['ffmpeg', '-y', '-i', wav_path, '-codec:a', 'libmp3lame', '-b:a', '128k', mp3_path]
    result = subprocess.run(cmd, capture_output=True, timeout=30)
    if result.returncode != 0:
        print(f"  ffmpeg error: {result.stderr.decode()[-200:]}")
    return result.returncode == 0

def generate_to_both_dirs(category, name, samples):
    """生成 WAV 后转为 MP3，同时放到 flutter 和 shared 目录"""
    for base in [BASE_DIR_FLUTTER, BASE_DIR_SHARED]:
        target_dir = os.path.join(base, category)
        ensure_dir(target_dir)
        wav_path = os.path.join(target_dir, name.replace('.mp3', '.wav'))
        mp3_path = os.path.join(target_dir, name)
        write_wav(wav_path, samples)
        ok = wav_to_mp3(wav_path, mp3_path)
        if ok:
            os.remove(wav_path)
            print(f"  ✓ {mp3_path}")
        else:
            print(f"  ✗ ffmpeg failed, keeping WAV: {wav_path}")

# ============ 工具函数 ============

def sine(freq, t):
    return math.sin(2 * math.pi * freq * t)

def envelope(t, duration, attack=0.01, release=0.01):
    """简单淡入淡出包络"""
    if t < attack:
        return t / attack
    elif t > duration - release:
        return (duration - t) / release
    return 1.0

def noise():
    """白噪声 [-1, 1]"""
    return random.uniform(-1, 1)

def lerp(a, b, t):
    return a + (b - a) * t

def repeat_samples(samples, duration, sample_rate=SAMPLE_RATE):
    """重复样本直到达到指定时长"""
    total_needed = int(sample_rate * duration)
    if len(samples) >= total_needed:
        return samples[:total_needed]
    result = []
    while len(result) < total_needed:
        result.extend(samples)
    return result[:total_needed]

# ============ 各声音生成函数 ============

def gen_tiger_roar():
    """虎啸声 - 低频咆哮，带有频率下滑"""
    duration = 3.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.05, 0.3)
        # 基频从 200Hz 下滑到 80Hz
        freq = lerp(200, 80, t / duration)
        # 多次谐波叠加
        val = 0.5 * sine(freq, t) + 0.3 * sine(freq * 2, t) + 0.15 * sine(freq * 3, t) + 0.05 * noise()
        # 幅度调制（呼吸感）
        mod = 0.7 + 0.3 * math.sin(2 * math.pi * 3 * t)
        samples.append(val * env * mod * 0.8)
    return samples

def gen_lion_roar():
    """狮吼声 - 深沉有力，比虎啸更低频"""
    duration = 3.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.08, 0.4)
        freq = lerp(150, 60, t / duration)
        val = 0.5 * sine(freq, t) + 0.35 * sine(freq * 2, t) + 0.1 * sine(freq * 3, t) + 0.05 * noise()
        mod = 0.6 + 0.4 * math.sin(2 * math.pi * 2.5 * t)
        samples.append(val * env * mod * 0.85)
    return samples

def gen_leopard_growl():
    """猎豹叫声 - 中频嘶吼"""
    duration = 2.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.02, 0.2)
        freq = lerp(300, 150, t / duration)
        val = 0.4 * sine(freq, t) + 0.3 * sine(freq * 2.1, t) + 0.2 * sine(freq * 3.2, t) + 0.1 * noise()
        mod = 0.8 + 0.2 * math.sin(2 * math.pi * 5 * t)
        samples.append(val * env * mod * 0.7)
    return samples

def gen_elephant_roar():
    """大象怒吼 - 极低频，震撼"""
    duration = 4.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.1, 0.5)
        freq = lerp(80, 30, t / duration)
        val = 0.6 * sine(freq, t) + 0.3 * sine(freq * 2, t) + 0.1 * noise()
        mod = 0.7 + 0.3 * math.sin(2 * math.pi * 1.5 * t)
        samples.append(val * env * mod * 0.9)
    return samples

def gen_wolf_howl():
    """狼嚎声 - 长音上升后稳定"""
    duration = 4.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.1, 0.5)
        # 频率先升后稳
        if t < 0.5:
            freq = lerp(200, 400, t / 0.5)
        else:
            freq = 400 + 20 * math.sin(2 * math.pi * 0.5 * t)  # 微颤
        val = 0.5 * sine(freq, t) + 0.3 * sine(freq * 2, t) + 0.1 * sine(freq * 3, t) + 0.05 * noise()
        # 颤音
        vibrato = 1.0 + 0.02 * math.sin(2 * math.pi * 6 * t)
        samples.append(val * env * vibrato * 0.75)
    return samples

def gen_dog_bark():
    """狗吠声 - 短促有力的吠叫"""
    bark_duration = 0.3
    gap_duration = 0.2
    total_duration = 3.0
    samples = []
    t = 0
    while t < total_duration:
        # 一声吠叫
        for i in range(int(SAMPLE_RATE * bark_duration)):
            bt = i / SAMPLE_RATE
            env = envelope(bt, bark_duration, 0.01, 0.1)
            freq = lerp(400, 250, bt / bark_duration)
            val = 0.5 * sine(freq, bt) + 0.3 * sine(freq * 2, bt) + 0.2 * noise()
            samples.append(val * env * 0.8)
        # 间隔
        for i in range(int(SAMPLE_RATE * gap_duration)):
            samples.append(0.0)
        t += bark_duration + gap_duration
    return samples[:int(SAMPLE_RATE * total_duration)]

def gen_eagle_screech():
    """鹰啸声 - 高频尖锐"""
    duration = 2.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.05, 0.2)
        # 高频下滑
        freq = lerp(3000, 1500, t / duration)
        val = 0.4 * sine(freq, t) + 0.3 * sine(freq * 1.5, t) + 0.2 * sine(freq * 2, t) + 0.1 * noise()
        # 快速颤音
        mod = 0.8 + 0.2 * math.sin(2 * math.pi * 15 * t)
        samples.append(val * env * mod * 0.7)
    return samples

def gen_rooster_crow():
    """雄鸡啼鸣 - 先升后降的明亮叫声"""
    duration = 2.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.02, 0.3)
        # 频率先升后降
        if t < 0.4:
            freq = lerp(800, 2000, t / 0.4)
        elif t < 0.8:
            freq = lerp(2000, 2200, (t - 0.4) / 0.4)
        else:
            freq = lerp(2200, 1200, (t - 0.8) / (duration - 0.8))
        val = 0.5 * sine(freq, t) + 0.3 * sine(freq * 2, t) + 0.1 * sine(freq * 3, t) + 0.05 * noise()
        mod = 0.8 + 0.2 * math.sin(2 * math.pi * 8 * t)
        samples.append(val * env * mod * 0.75)
    return samples

def gen_mongoose_call():
    """獴叫声 - 短促高频叫声"""
    call_dur = 0.15
    gap_dur = 0.1
    total_dur = 2.0
    samples = []
    t = 0
    while t < total_dur:
        for i in range(int(SAMPLE_RATE * call_dur)):
            ct = i / SAMPLE_RATE
            env = envelope(ct, call_dur, 0.005, 0.03)
            freq = lerp(1500, 3000, ct / call_dur)
            val = 0.4 * sine(freq, ct) + 0.3 * sine(freq * 2, ct) + 0.2 * noise()
            samples.append(val * env * 0.65)
        for i in range(int(SAMPLE_RATE * gap_dur)):
            samples.append(0.0)
        t += call_dur + gap_dur
    return samples[:int(SAMPLE_RATE * total_dur)]

def gen_cat_meow():
    """猫叫声 - 柔和的喵叫"""
    duration = 1.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.02, 0.3)
        # 频率先升后降
        if t < 0.3:
            freq = lerp(500, 800, t / 0.3)
        else:
            freq = lerp(800, 400, (t - 0.3) / (duration - 0.3))
        val = 0.5 * sine(freq, t) + 0.3 * sine(freq * 2, t) + 0.1 * sine(freq * 3, t) + 0.05 * noise()
        mod = 0.9 + 0.1 * math.sin(2 * math.pi * 4 * t)
        samples.append(val * env * mod * 0.65)
    return samples

def gen_gunshot():
    """枪声 - 尖锐爆裂"""
    duration = 1.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        if t < 0.01:
            # 初始爆裂
            env = t / 0.01
            val = noise() * 1.0
        elif t < 0.05:
            # 快速衰减
            env = 1.0 - (t - 0.01) / 0.04
            val = 0.7 * noise() + 0.3 * sine(150, t)
        elif t < 0.2:
            # 回响
            env = 0.3 * math.exp(-10 * (t - 0.05))
            val = 0.5 * noise() + 0.5 * sine(100, t)
        else:
            # 低频回响
            env = 0.1 * math.exp(-5 * (t - 0.2))
            val = sine(80, t)
        samples.append(val * env * 0.95)
    return samples

def gen_campfire():
    """篝火爆裂声 - 噼啪声"""
    duration = 5.0
    samples = [0.0] * int(SAMPLE_RATE * duration)
    # 随机产生噼啪声
    num_crackles = 60
    for _ in range(num_crackles):
        pos = random.uniform(0, duration - 0.05)
        crackle_dur = random.uniform(0.01, 0.04)
        start_sample = int(pos * SAMPLE_RATE)
        for j in range(int(crackle_dur * SAMPLE_RATE)):
            idx = start_sample + j
            if idx < len(samples):
                ct = j / SAMPLE_RATE
                env = envelope(ct, crackle_dur, 0.001, 0.005)
                freq = random.uniform(1000, 6000)
                val = 0.3 * noise() + 0.2 * sine(freq, ct)
                samples[idx] += val * env * random.uniform(0.3, 1.0)
    # 添加低频底噪模拟火焰
    for i in range(len(samples)):
        t = i / SAMPLE_RATE
        samples[i] += 0.03 * noise() + 0.02 * sine(60, t)
    # 归一化
    max_val = max(abs(s) for s in samples) or 1.0
    samples = [s / max_val * 0.7 for s in samples]
    return samples

def gen_metal_bang():
    """金属撞击 - 尖锐金属碰撞声"""
    duration = 2.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        if t < 0.005:
            env = t / 0.005
            val = noise() * 1.0
        elif t < 0.05:
            env = 1.0 - (t - 0.005) / 0.045
            val = 0.6 * noise() + 0.4 * sine(4000, t)
        elif t < 0.3:
            decay = math.exp(-15 * (t - 0.05))
            val = 0.4 * noise() + 0.3 * sine(3500, t) + 0.3 * sine(5000, t)
            env = decay
        else:
            decay = math.exp(-8 * (t - 0.3))
            val = 0.5 * sine(3000, t) + 0.5 * sine(4500, t)
            env = decay
        samples.append(val * env * 0.85)
    return samples

def gen_metal_clang():
    """金属碰撞声 - 较长的金属共鸣"""
    duration = 2.5
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        if t < 0.003:
            env = t / 0.003
            val = noise() * 1.0
        elif t < 0.03:
            env = 1.0 - (t - 0.003) / 0.027
            val = 0.5 * noise() + 0.3 * sine(2500, t) + 0.2 * sine(5000, t)
        else:
            decay = math.exp(-6 * (t - 0.03))
            # 金属共振频率
            val = 0.3 * sine(2500, t) + 0.3 * sine(3750, t) + 0.2 * sine(5000, t) + 0.1 * sine(6250, t)
            env = decay
        samples.append(val * env * 0.8)
    return samples

def gen_crowd_shout():
    """人群呐喊 - 多层噪声叠加"""
    duration = 3.0
    samples = []
    random.seed(42)
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.2, 0.3)
        # 多层噪声模拟人群
        val = 0.3 * noise() + 0.2 * sine(200 + 100 * math.sin(2 * math.pi * 2 * t), t) + \
              0.15 * sine(400, t) + 0.15 * sine(600 + 50 * math.sin(2 * math.pi * 3 * t), t) + \
              0.1 * sine(800, t) + 0.1 * noise()
        # 幅度起伏
        mod = 0.7 + 0.3 * math.sin(2 * math.pi * 1.5 * t + 0.5 * math.sin(2 * math.pi * 0.5 * t))
        samples.append(val * env * mod * 0.8)
    return samples

def gen_whistle():
    """尖锐哨声 - 高频纯音"""
    duration = 2.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.05, 0.1)
        freq = lerp(2500, 3500, t / duration) + 100 * math.sin(2 * math.pi * 3 * t)
        val = 0.6 * sine(freq, t) + 0.3 * sine(freq * 2, t) + 0.1 * noise()
        samples.append(val * env * 0.75)
    return samples

def gen_vibration():
    """割草机震动声 - 低频振动"""
    duration = 4.0
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.1, 0.2)
        # 低频振动
        val = 0.4 * sine(50, t) + 0.3 * sine(100, t) + 0.15 * sine(150, t) + \
              0.1 * sine(200, t) + 0.05 * noise()
        mod = 0.9 + 0.1 * math.sin(2 * math.pi * 8 * t)
        samples.append(val * env * mod * 0.85)
    return samples

def gen_slapping():
    """拍打声 - 短促的拍击"""
    slap_dur = 0.08
    total_dur = 2.0
    gap_dur = 0.4
    samples = []
    t = 0
    while t < total_dur:
        for i in range(int(SAMPLE_RATE * slap_dur)):
            st = i / SAMPLE_RATE
            env = envelope(st, slap_dur, 0.002, 0.02)
            val = 0.5 * noise() + 0.3 * sine(800, st) + 0.2 * sine(1500, st)
            samples.append(val * env * 0.8)
        for i in range(int(SAMPLE_RATE * gap_dur)):
            samples.append(0.0)
        t += slap_dur + gap_dur
    return samples[:int(SAMPLE_RATE * total_dur)]

def gen_ultrasonic(freq_khz):
    """超声波 - 指定频率的正弦波"""
    freq = freq_khz * 1000
    duration = 10.0  # 超声波10秒循环
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.01, 0.01)
        val = sine(freq, t)
        samples.append(val * env * 0.8)
    return samples

def gen_broom():
    """扫帚清扫声 - 刷刷声"""
    duration = 3.0
    samples = []
    random.seed(77)
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.1, 0.2)
        # 模拟扫帚的刷刷声 - 带通噪声
        raw = noise()
        # 简单低通滤波（用滑动平均近似）
        val = 0.6 * raw + 0.2 * sine(1000 + 500 * math.sin(2 * math.pi * 2 * t), t) + \
              0.15 * sine(2000, t) + 0.05 * sine(500, t)
        # 周期性起伏模拟扫动
        mod = 0.5 + 0.5 * abs(math.sin(2 * math.pi * 1.5 * t))
        samples.append(val * env * mod * 0.65)
    return samples

def gen_knocking():
    """敲击声 - 规律的叩击"""
    knock_dur = 0.05
    total_dur = 3.0
    gap_dur = 0.5
    samples = []
    t = 0
    while t < total_dur:
        for i in range(int(SAMPLE_RATE * knock_dur)):
            kt = i / SAMPLE_RATE
            env = envelope(kt, knock_dur, 0.001, 0.01)
            val = 0.5 * noise() + 0.3 * sine(1200, kt) + 0.2 * sine(2400, kt)
            samples.append(val * env * 0.8)
        for i in range(int(SAMPLE_RATE * gap_dur)):
            samples.append(0.0)
        t += knock_dur + gap_dur
    return samples[:int(SAMPLE_RATE * total_dur)]

def gen_spray():
    """喷雾剂声 - 嘶嘶声"""
    duration = 3.0
    samples = []
    random.seed(88)
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.05, 0.15)
        # 嘶嘶声 = 高通噪声
        raw = noise()
        val = 0.5 * raw + 0.25 * sine(4000, t) + 0.15 * sine(6000, t) + 0.1 * sine(2000, t)
        mod = 0.8 + 0.2 * math.sin(2 * math.pi * 5 * t)
        samples.append(val * env * mod * 0.65)
    return samples

def gen_wind():
    """风声 - 低频呼啸"""
    duration = 5.0
    samples = []
    random.seed(99)
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = envelope(t, duration, 0.3, 0.5)
        # 风声 = 低频噪声 + 缓慢频率调制
        raw = noise()
        mod_freq = 0.3 + 0.2 * math.sin(2 * math.pi * 0.1 * t)
        val = 0.4 * raw + 0.3 * sine(200, t) + 0.15 * sine(400 + 100 * math.sin(2 * math.pi * mod_freq * t), t) + \
              0.1 * sine(100, t) + 0.05 * sine(800, t)
        mod = 0.6 + 0.4 * math.sin(2 * math.pi * 0.2 * t)
        samples.append(val * env * mod * 0.6)
    return samples

def gen_footsteps():
    """脚步声 - 规律的脚步"""
    step_dur = 0.12
    total_dur = 3.0
    gap_dur = 0.45
    samples = []
    t = 0
    while t < total_dur:
        for i in range(int(SAMPLE_RATE * step_dur)):
            st = i / SAMPLE_RATE
            env = envelope(st, step_dur, 0.002, 0.03)
            val = 0.4 * noise() + 0.3 * sine(400, st) + 0.2 * sine(800, st) + 0.1 * sine(150, st)
            samples.append(val * env * 0.7)
        for i in range(int(SAMPLE_RATE * gap_dur)):
            samples.append(0.0)
        t += step_dur + gap_dur
    return samples[:int(SAMPLE_RATE * total_dur)]


# ============ 所有需要的声音文件 ============

SOUNDS = [
    # animal/
    ("animal", "tiger_roar.mp3",    gen_tiger_roar),
    ("animal", "lion_roar.mp3",     gen_lion_roar),
    ("animal", "leopard_growl.mp3", gen_leopard_growl),
    ("animal", "elephant_roar.mp3", gen_elephant_roar),
    ("animal", "wolf_howl.mp3",     gen_wolf_howl),
    ("animal", "dog_bark.mp3",      gen_dog_bark),
    ("animal", "eagle_screech.mp3", gen_eagle_screech),
    ("animal", "rooster_crow.mp3",  gen_rooster_crow),
    ("animal", "mongoose_call.mp3", gen_mongoose_call),
    ("animal", "cat_meow.mp3",      gen_cat_meow),

    # firecracker/
    ("firecracker", "gunshot.mp3",  gen_gunshot),
    ("firecracker", "campfire.mp3", gen_campfire),

    # alarm/
    ("alarm", "crowd_shout.mp3", gen_crowd_shout),
    ("alarm", "whistle.mp3",     gen_whistle),
    ("alarm", "vibration.mp3",   gen_vibration),
    ("alarm", "slapping.mp3",    gen_slapping),
    ("alarm", "broom.mp3",       gen_broom),
    ("alarm", "spray.mp3",       gen_spray),
    ("alarm", "wind.mp3",        gen_wind),
    ("alarm", "footsteps.mp3",   gen_footsteps),

    # metal/
    ("metal", "metal_bang.mp3",  gen_metal_bang),
    ("metal", "metal_clang.mp3", gen_metal_clang),
    ("metal", "knocking.mp3",    gen_knocking),

    # ultrasonic/
    ("ultrasonic", "ultrasonic_18khz.mp3", lambda: gen_ultrasonic(18)),
    ("ultrasonic", "ultrasonic_20khz.mp3", lambda: gen_ultrasonic(20)),
    ("ultrasonic", "ultrasonic_22khz.mp3", lambda: gen_ultrasonic(22)),
]


def main():
    print("🎵 开始生成 Shoo 声音文件...")
    print(f"  共 {len(SOUNDS)} 个声音文件待生成\n")

    for category, name, gen_func in SOUNDS:
        print(f"生成: {category}/{name}")
        samples = gen_func()
        generate_to_both_dirs(category, name, samples)

    print(f"\n✅ 完成！共生成 {len(SOUNDS)} 个声音文件")
    print(f"  文件位置:")
    print(f"    - {BASE_DIR_FLUTTER}/")
    print(f"    - {BASE_DIR_SHARED}/")


if __name__ == "__main__":
    main()
