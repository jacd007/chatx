# material_ui interop check

chatx is built on `package:flutter/material.dart`. Apps that migrated to the
`material_ui` package host it through `MaterialUiCompatibilityBridge`. These
tests run in CI on the latest stable Flutter to keep that setup working.

```bash
flutter test
```
