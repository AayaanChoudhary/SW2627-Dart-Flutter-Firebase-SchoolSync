SchoolSync/
│
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── firebase.json
│
├── assets/
│   ├── images/                         # Sahaj: Frontend Developer
│   ├── icons/                          # Sahaj: Frontend Developer
│   └── fonts/                          # Sahaj: Frontend Developer
│
├── lib/
│   │
│   ├── main.dart                       # Shared: App entry point
│   │
│   ├── firebase_options.dart            # Kavya: Backend Developer
│   │
│   ├── app/
│   │   ├── app.dart                    # Sahaj: Frontend Developer
│   │   ├── routes.dart                 # Sahaj: Frontend Developer
│   │   └── theme.dart                  # Sahaj: Frontend Developer
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart      # Sahaj
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart         # Sahaj
│   │   │   └── formatters.dart         # Sahaj
│   │   │
│   │   ├── errors/
│   │   │   └── app_exceptions.dart     # Kavya
│   │   │
│   │   └── widgets/
│   │       ├── app_button.dart         # Sahaj
│   │       ├── app_text_field.dart     # Sahaj
│   │       ├── loading_indicator.dart  # Sahaj
│   │       ├── error_view.dart         # Sahaj
│   │       └── empty_state.dart        # Sahaj
│   │
│   ├── models/
│   │   ├── user_model.dart             # Aayaan: Database Incharge
│   │   ├── school_model.dart           # Aayaan
│   │   ├── attendance_model.dart       # Aayaan
│   │   ├── fee_model.dart              # Aayaan
│   │   ├── exam_model.dart             # Aayaan
│   │   └── feedback_model.dart         # Aayaan
│   │
│   ├── services/
│   │   ├── auth_service.dart           # Kavya: Backend Developer
│   │   ├── attendance_service.dart     # Kavya + Aayaan
│   │   ├── fee_service.dart            # Kavya + Aayaan
│   │   ├── exam_service.dart           # Kavya + Aayaan
│   │   ├── feedback_service.dart       # Kavya + Aayaan
│   │   └── storage_service.dart        # Kavya
│   │
│   └── features/
│       │
│       ├── auth/
│       │   ├── screens/
│       │   │   ├── login_screen.dart       # Sahaj
│       │   │   └── register_screen.dart    # Sahaj
│       │   │
│       │   ├── widgets/
│       │   │   └── auth_form.dart          # Sahaj
│       │   │
│       │   └── auth_controller.dart        # Kavya
│       │
│       ├── school/
│       │   ├── dashboard/
│       │   │   ├── school_dashboard_screen.dart  # Sahaj
│       │   │   └── widgets/                     # Sahaj
│       │   │
│       │   ├── attendance/
│       │   │   ├── attendance_screen.dart       # Sahaj
│       │   │   └── attendance_controller.dart   # Kavya
│       │   │
│       │   ├── fees/
│       │   │   ├── fees_screen.dart             # Sahaj
│       │   │   └── fee_controller.dart          # Kavya
│       │   │
│       │   ├── exams/
│       │   │   ├── exams_screen.dart            # Sahaj
│       │   │   └── exam_controller.dart         # Kavya
│       │   │
│       │   └── feedback/
│       │       ├── feedback_screen.dart         # Sahaj
│       │       └── feedback_controller.dart     # Kavya
│       │
│       └── district/
│           ├── dashboard/
│           │   ├── district_dashboard_screen.dart  # Sahaj
│           │   └── widgets/                        # Sahaj
│           │
│           ├── schools/
│           │   ├── schools_screen.dart             # Sahaj
│           │   ├── school_detail_screen.dart       # Sahaj
│           │   └── school_controller.dart          # Kavya + Aayaan
│           │
│           ├── attendance/
│           │   ├── attendance_monitor_screen.dart  # Sahaj
│           │   └── attendance_monitor_controller.dart # Kavya
│           │
│           ├── fees/
│           │   ├── fee_monitor_screen.dart         # Sahaj
│           │   └── fee_monitor_controller.dart     # Kavya
│           │
│           ├── exams/
│           │   ├── exam_overview_screen.dart       # Sahaj
│           │   └── exam_controller.dart            # Kavya
│           │
│           ├── feedback/
│           │   ├── feedback_screen.dart            # Sahaj
│           │   ├── create_feedback_screen.dart     # Sahaj
│           │   └── feedback_controller.dart        # Kavya
│           │
│           └── alerts/
│               ├── alerts_screen.dart              # Sahaj
│               └── alert_service.dart              # Kavya
│
├── firestore/
│   ├── data_model.md                    # Aayaan: Database Incharge
│   ├── firestore.rules                  # Aayaan
│   └── firestore.indexes.json           # Aayaan
│
├── storage/
│   └── storage.rules                    # Aayaan
│
├── test/
│   ├── models/                          # Aayaan
│   ├── services/                        # Kavya
│   ├── features/                        # Sahaj + feature owner
│   └── widgets/                         # Sahaj
│
└── docs/
    ├── architecture.md                  # Shared
    ├── firestore-schema.md              # Aayaan
    ├── api-firebase-flow.md             # Kavya
    └── ui-navigation.md                 # Sahaj