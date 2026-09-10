import re

with open('lib/l10n/app_localizations.dart', 'r') as f:
    lines = f.readlines()

fixed = []
removed = 0
for line in lines:
    stripped = line.rstrip('\n')
    # Detect garbage: line is just '});' followed by fragment content (not a valid continuation)
    # Valid continuation after '});' is empty (just '});')
    # Garbage looks like: });safety',  });d safety',  });  });y', etc.
    if re.match(r'^\s*\}\);.+$', stripped):
        # This line starts with '});' and has more content — it's garbage
        removed += 1
        continue
    fixed.append(line)

with open('lib/l10n/app_localizations.dart', 'w') as f:
    f.writelines(fixed)

print(f'Done. Removed {removed} garbage lines, {len(fixed)} lines remain.')
