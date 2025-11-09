# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Commands

- Build (Debug, iOS Simulator):
  - xcodebuild -project "Money³.xcodeproj" -scheme "Money³" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' build
- Clean:
  - xcodebuild -project "Money³.xcodeproj" -scheme "Money³" -configuration Debug clean
- Test:
  - No test target found. If tests are added later:
    - Run all tests: xcodebuild test -project "Money³.xcodeproj" -scheme "Money³" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0'
    - Run a single test: xcodebuild test -project "Money³.xcodeproj" -scheme "Money³" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' -only-testing:<TestTarget>/<TestClass>/<testMethod>
- Archive (Release):
  - xcodebuild -project "Money³.xcodeproj" -scheme "Money³" -configuration Release -archivePath build/Money3.xcarchive archive
- Lint:
  - No linter configuration detected (e.g., SwiftLint/SwiftFormat not present).

Notes:
- Minimum iOS version is 26.0; use an iOS 26.0 simulator (e.g., iPhone 17 Pro) for CLI builds/tests.
- The project/target/scheme name contains a superscript character (³); make sure to quote it in shell commands as shown above.

## Architecture overview

### Modern SwiftUI Architecture (Feature-based with Services)

This project uses a hybrid approach combining feature-based organization with service layers for clean separation of concerns.

**App Layer**
- App entry: `Money³/App/FinanceTrackerApp.swift` defines the main app with SwiftData model container for Expense
- Primary navigation: `Money³/App/ContentView.swift` hosts a TabView with two main features: AddExpense and ExpenseList

**Models Layer** (`Money³/Models/`)
- `Expense.swift` - Core SwiftData @Model for expense persistence (id, amount, category, desc, date, paymentMethod)
- `ExtractedExpense.swift` - @Generable struct for AI processing and ExpenseCategory enum with icons/colors
- `CategoryTotal.swift` - Supporting model for analytics data

**Services Layer** (`Money³/Services/`)
- `ExpenseService.swift` - Business logic for expense operations, analytics, and SwiftData CRUD (@Observable)
- `SpeechService.swift` - Speech recognition and audio processing (@Observable)
- `OCRService.swift` - Vision framework operations for receipt text extraction
- `AIProcessingService.swift` - Foundation Models integration with fallback pattern parsing

**Components Layer** (`Money³/Components/`)
- `ExpenseRow.swift` - Reusable expense list row component
- `FilterChip.swift` - Reusable category filter chip component

**Features Layer** (organized by domain)
- **AddExpense feature** (`Money³/Features/AddExpense/`)
  - `AddExpenseView.swift` - Main feature hub with three input method options
  - **VoiceInput sub-feature** (`VoiceInput/`)
    - `VoiceInputView.swift` - Voice input UI with recording visualization
    - `VoiceInputViewModel.swift` - @Observable ViewModel using SpeechService and AIProcessingService
  - **ReceiptScanner sub-feature** (`ReceiptScanner/`)
    - `ReceiptScannerView.swift` - Receipt image picker and processing UI
    - `ReceiptScannerViewModel.swift` - @Observable ViewModel using OCRService and AIProcessingService
  - **ManualEntry sub-feature** (`ManualEntry/`)
    - `ManualEntryView.swift` - Direct form entry for expenses
- **ExpenseList feature** (`Money³/Features/ExpenseList/`)
  - `ExpenseListView.swift` - List with filtering, grouping by date, and search functionality

### Modern SwiftUI Patterns Used
- **@Observable** macro for all ViewModels (replacing ObservableObject)
- **SwiftData** with @Model and @Query for persistence
- **Service injection** pattern for clean separation of concerns
- **Feature-based organization** for scalability
- **Foundation Models** integration with fallback patterns
- **Modern navigation** with sheet presentations

Project configuration highlights
- Xcode project: Money³.xcodeproj with a single target/scheme named “Money³”.
- Generated Info.plist: The target sets GENERATE_INFOPLIST_FILE = YES and declares privacy usage keys via build settings (camera, microphone, photo library, speech recognition). Keep using build settings for app metadata; no manual Info.plist file exists in the repo.
- Deployment/Devices: IPHONEOS_DEPLOYMENT_TARGET = 26.0; TARGETED_DEVICE_FAMILY = "1,2" (iPhone and iPad).

## Repository notes gathered during analysis
- No existing WARP.md, README.md, CLAUDE.md, Cursor rules, or Copilot instructions were found.
- No test targets or test plans were found.
- No SwiftLint/SwiftFormat configuration files were found.
- Key source files live under Money³/; the Xcode project file is Money³.xcodeproj/project.pbxproj.
