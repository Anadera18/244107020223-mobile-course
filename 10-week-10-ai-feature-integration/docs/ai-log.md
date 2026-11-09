# AI Development Log — Week 10

## Feature and context

Feature: Gemini powered chat for a campus study assistant, with secure key configuration, bounded input/output, loading state, friendly API errors, and a clearly labeled offline example response.

The Week 10 folder was a blank scaffold (`lib/`, `docs/`, and `screenshots/` only). This implementation keeps the API service separate from the chat UI and stores the API key through `flutter_secure_storage`. Tests inject an in-memory key store and a mocked HTTP client, so verification is repeatable and does not consume API quota.

The API key supplied in chat is deliberately not recorded in this repository, screenshots, or test fixtures. It was exposed in conversation history; revoke it and create a replacement before real use.

## Five-slot prompt

```text
Role: Senior Flutter engineer reviewing an AI feature for a mobile app.
Context: Blank Flutter Week 10 scaffold. Use Gemini API, secure storage, Material 3, and keep network code outside widgets.
Task: Implement one useful campus study assistant chat feature. Include settings to save/delete the API key, loading feedback, friendly error handling, and an offline fallback.
Limits: Never hardcode or log secrets. Never send private student identifiers. Limit user input and generated output. Keep conversation in memory. Make network behavior mockable and test it without real API calls.
Output: Runnable Flutter source, unit/widget tests, a README report with risk/mitigation and reflection, AI log, and screenshots of test success and app UI.
```

## Initial AI proposal / output summary

The initial design proposal used a Flutter chat screen that posts the prompt to a Gemini REST endpoint, reads the first candidate's text, and renders a helpful answer. It mentioned secure storage and a try/catch fallback, but needed refinement around key exposure, current model choice, malformed payloads, mockable tests, and visible distinction between generated and offline answers.

## Verification and decisions

| Proposal | Decision | Reason and evidence |
| --- | --- | --- |
| Store key with `flutter_secure_storage` | Accept | The key is entered in app settings, stored by the platform plugin, masked in the field, removable, and absent from repository files. |
| Put the key in a URL query parameter | Reject / refactor | Query strings can appear in logs and diagnostics. The service sends `x-goog-api-key` as an HTTPS request header. |
| Parse `candidates[0]` without validating shape | Reject / fix | Empty or malformed candidate arrays caused a raw `StateError` in the first test run. The service now catches malformed payload shapes and returns a friendly `AiServiceException`. |
| Show a generic answer when the service fails | Refactor | A local answer is explicitly labeled `MODE OFFLINE`; the status banner explains that the API call failed, so users do not mistake fallback copy for a Gemini response. |
| Send conversation history and student profile as context | Reject | The demo sends only the current typed question and does not persist chat history. This reduces unnecessary disclosure and request cost. |
| Bound request size and generated output | Accept | UI caps input at 500 characters; API request asks for at most 256 output tokens. Tests check the input limit and request configuration. |
| Call live Gemini from tests | Reject | Mock HTTP tests verify request structure, response parsing, missing key, 429, and malformed payloads without exposing the key or spending quota. |

## System prompt

```text
You are Campus AI Assistant, a friendly academic helper. Answer in Indonesian in at most three short sentences. Do not request or reveal private student information. If unsure, say so and suggest checking an official campus source.
```

## User prompt and initial AI output

Example user prompt used for the feature walkthrough: `Bagaimana cara mulai belajar Flutter dengan teratur?`

Initial proposed response (illustrative): `Mulailah dari dasar Dart, lalu pelajari widget dan layout Flutter. Buat proyek kecil dan praktikkan sedikit demi sedikit setiap hari.`

That sample is an illustrative initial AI output, not a live API result. Automated tests use mocked Gemini JSON and assert the parsed response. The live app should be configured with a rotated key to capture an actual provider response.

## Test and analysis evidence

Commands run in this directory:

```text
flutter pub get                  completed
dart format .                    completed
flutter test --reporter expanded All tests passed (9 tests)
flutter analyze                  No issues found
```

The UI screenshot is [`../screenshots/chat-home.png`](../screenshots/chat-home.png). The captured terminal output is [`../screenshots/flutter-test-passed.txt`](../screenshots/flutter-test-passed.txt).

## Explain the implementation

`AiService` owns HTTPS request creation, the system instruction, response parsing, and provider error mapping. It reads the API key through the `ApiKeyStore` interface, making the implementation straightforward to test with an in-memory fake. `SecureApiKeyStore` persists the key using platform secure storage. `ChatPage` owns transient messages and UI state, prevents a second in-flight request, caps input, and distinguishes API errors from explicitly marked offline sample content.

This is a client-side learning example. Secure storage protects a key at rest, but a distributed mobile app cannot keep an API credential secret from a determined device owner. A production deployment should proxy model calls through an authenticated backend with server-side quota controls and abuse monitoring.

## Reflection

- **Which AI feature and why?** A chat assistant demonstrates the core mobile AI flow and exposes the user experience around latency, errors, and model output.
- **How is privacy protected?** The user chooses what to send; the app excludes private student details by design guidance, sends only the current question, and does not persist the transcript. The key is in device secure storage and can be deleted.
- **What fallback is available?** On a missing key or service error, the app displays a clear status and a local sample response labeled offline. It does not claim that the fallback came from Gemini.
- **What did I learn about mobile AI UX?** A responsive loading state, bounded prompts, honest error messaging, and a clearly identified fallback are necessary to make a network AI feature understandable and safe to try.
