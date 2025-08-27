# Task Manager Mobile App
This is the mobile frontend for a Task Manager application, built with Flutter. The app allows users to create, view, update, and delete tasks, and it connects to a separate RESTful API backend to manage all task data.

## Features
Task List: Display all tasks in a clean list view.

Filtering: Filter tasks by status (todo, in_progress, done) and priority (low, medium, high).

Sorting: Sort tasks by title (alphabetically) or priority, in both ascending and descending order.

Pagination: Handle large lists of tasks with "Load more" functionality.

Task Form: A dedicated screen to create new tasks or edit existing ones.

Validation: Required fields are enforced to ensure data integrity.

# Technologies Used :
Framework: Flutter (3.9.0+)

State Management: provider

Networking: `http`

Environment Variables: `flutter_dotenv`

## Setup and Run Instructions
Follow these steps to get a local copy of the app up and running on your machine.

## 1. Prerequisites
Flutter SDK: Make sure you have the Flutter SDK installed on your system.

Android/iOS Setup: Ensure your mobile development environment is configured to run apps on an emulator, a physical device, or your web browser.

## 2. Clone the Repository

Clone the project from GitHub and navigate into the directory.
```bash
git clone https://github.com/your-username/task-manager-frontend.git
cd task-manager-frontend
```
## 3. Configure Environment Variables
Create a .env file in the root directory of the project. This file will hold the configuration for connecting to your backend API.
```bash
touch .env
```

## Add the following content to your new .env file, replacing the placeholder values with your actual backend URL and API key.
```bash
API_BASE_URL=http://<backend-url>:8000/api
API_KEY=<your-api-key>

```

#### Note on URL: If you are running the app on a physical device, the API_BASE_URL should be your computer's local IP address (e.g., 192.168.1.5:8000/api), not localhost or 127.0.0.1.

## 4. Install Dependencies
Run the following command to get all the required packages from your pubspec.yaml file.
```bash
flutter pub get
```

## 5. Run the Application
You can now run the app on your connected device or emulator.
```bash
flutter run
```

## If you want to build a release APK for distribution, use the following command to remove the "DEBUG" banner.
```bash
flutter build apk --release
```
