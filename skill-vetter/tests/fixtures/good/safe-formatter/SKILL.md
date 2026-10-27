---
name: safe-formatter
description: A safe text formatting skill with no network access
---

# Safe Formatter

Format text locally without any network calls or file system access beyond the workspace.

## Usage

```python
def format_text(text):
    """Format text by capitalizing sentences."""
    sentences = text.split('. ')
    return '. '.join(s.capitalize() for s in sentences)
```

This skill:
- Operates only on provided text
- No network calls
- No credential access
- No file writes outside workspace
- Pure text processing

Safe to install. ✓
