# MediFlow

## Overview
MediFlow is a Flutter-based healthcare application designed to enhance patient-doctor interactions through an integrated AI-powered chatbot. The app allows users to log in, chat about symptoms, medications, and chronic conditions, and generate pre-visit reports. Built with a web-compatible frontend, MediFlow leverages Firebase for authentication and Firestore for real-time data management, with an AI backend powered by an external API (e.g., OpenRouter). This project aims to provide a modern, accessible solution for healthcare management, suitable for both web and potential mobile deployment.

## Features
- **User Authentication**: Secure login with email, Google, and Apple credentials using Firebase Authentication.
- **AI Chatbot**: Interactive chatbot to discuss general health, acute symptoms, chronic conditions, and medications.
- **Pre-Visit Reports**: Generate detailed reports based on chat history for medical consultations.
- **Role-Based Access**: Supports patient and doctor roles with invite code functionality for patient-doctor connections.
- **Real-Time Data**: Utilizes Firestore for storing and streaming chat messages and user data.
- **Web Compatibility**: Fully functional web frontend built with Flutter.

## Technologies Used
- **Flutter**: Cross-platform framework for building the UI and logic.
- **Dart**: Programming language for both frontend and backend logic.
- **Firebase**: Authentication and Firestore for user management and data storage.
- **OpenRouter API**: Powers the AI chatbot with natural language processing.
- **HTTP**: For API requests to the AI service.
- **Git**: Version control for project management.

## Prerequisites
- **Flutter SDK**: Ensure Flutter is installed (v3.0.0 or later recommended). Install via [flutter.dev](https://flutter.dev/docs/get-started/install).
- **Dart**: Included with Flutter.
- **Firebase Account**: Set up a Firebase project and download configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
- **OpenRouter API Key**: Obtain an API key from [openrouter.ai](https://openrouter.ai) for the chatbot functionality.
- **IDE**: Visual Studio Code, Android Studio, or IntelliJ IDEA with Flutter/Dart plugins.
- **Node.js (Optional)**: For running a local server if using the server-side backend option.

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/mediflow.git
cd mediflow
