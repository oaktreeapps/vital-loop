# Third-party notices

This project is released under the Apache License, Version 2.0 (see
[LICENSE](LICENSE)). It also contains, or is adapted from, the code below,
which keeps its own license.

## Body map (Apache License 2.0)

The body map (`client/lib/models/body_map/` and
`client/lib/catalog/body_map_picker/`) comes from the Daily Health Tracker project, Copyright 2026 The Daily Health
Tracker Authors, licensed under the Apache License, Version 2.0. Each of these
files keeps its Apache 2.0 header, followed by a note that Oaktreeapps changed
it. You may obtain a copy of the license at
https://www.apache.org/licenses/LICENSE-2.0.

## genui examples (BSD 3-Clause)

The app's structure (a `Transport` feeding a `SurfaceController`, an ADK agent
served over A2A) is adapted from the
[genui examples](https://github.com/flutter/genui/tree/main/examples), mainly
Verdure and simple_chat.

```
Copyright 2025 The Flutter Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

Packages the app and backend depend on (genui, ADK, a2a-sdk, pdf, …) are
downloaded by `flutter pub get` and `pip install` and keep their own licenses.
