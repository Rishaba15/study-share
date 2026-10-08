
# StudyShare – Smart Notes v1.2

Adds the first AI Summarizer UI layer on top of v1.1.

Included:
- Department selection
- 8 semesters per department
- Department-specific subjects
- Department-aware search
- Real file picker for notes
- Upload UI with progress
- AI Summarizer tab
- PDF/DOC/DOCX/TXT selection for AI
- AI summary result UI
- Easy Explanation UI
- Important Points UI
- Practice Questions UI
- Quick Revision / Ask AI placeholders

Important:
The AI result is currently a demo UI. No external AI API key is embedded.
Actual AI processing should be connected through a secure backend in the next stage.

Run on mobile device/emulator:
```cmd
flutter clean
flutter pub get
flutter run
```

For Android specifically:
```cmd
flutter run -d android
```

For iOS simulator:
```cmd
flutter run -d ios
```
