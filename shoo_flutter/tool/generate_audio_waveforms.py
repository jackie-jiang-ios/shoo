#!/usr/bin/env python3

import array
import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOUNDS_DIR = ROOT / "assets" / "sounds"
OUTPUT_DIR = ROOT / "assets" / "waveforms"
OUTPUT_FILE = OUTPUT_DIR / "audio_waveforms.json"
SAMPLE_RATE = 8000
BIN_COUNT = 56


def get_duration_seconds(file_path: Path) -> float:
    output = subprocess.check_output(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            str(file_path),
        ],
        text=True,
    ).strip()
    return round(float(output or 0), 3)


def get_peaks(file_path: Path) -> list[float]:
    result = subprocess.run(
        [
            "ffmpeg",
            "-v",
            "error",
            "-i",
            str(file_path),
            "-ac",
            "1",
            "-ar",
            str(SAMPLE_RATE),
            "-f",
            "f32le",
            "-",
        ],
        stdout=subprocess.PIPE,
        check=True,
    )

    samples = array.array("f")
    samples.frombytes(result.stdout)
    if not samples:
        return [0.0] * BIN_COUNT

    chunk_size = max(1, len(samples) // BIN_COUNT)
    peaks: list[float] = []

    for index in range(BIN_COUNT):
        start = index * chunk_size
        end = len(samples) if index == BIN_COUNT - 1 else min(
            len(samples), (index + 1) * chunk_size
        )
        segment = samples[start:end]
        if not segment:
            peaks.append(0.0)
            continue

        peak = max(abs(sample) for sample in segment)
        peaks.append(round(min(1.0, peak ** 0.65), 4))

    return peaks


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    waveforms: dict[str, dict[str, object]] = {}

    for file_path in sorted(SOUNDS_DIR.rglob("*.mp3")):
        asset_path = file_path.relative_to(ROOT).as_posix()
        waveforms[asset_path] = {
            "durationSeconds": get_duration_seconds(file_path),
            "peaks": get_peaks(file_path),
        }

    OUTPUT_FILE.write_text(
        json.dumps(waveforms, ensure_ascii=True, separators=(",", ":")),
        encoding="utf-8",
    )
    print(f"Generated {len(waveforms)} waveform entries -> {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
