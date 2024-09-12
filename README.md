# Northchess: Multiplayer Chess Game (Frontend)

Welcome to **Northchess**, an online multiplayer chess game developed as part of the Northcoders Software Development Bootcamp. This Flutter-based project showcases our team's skills in mobile and game development.

## Project Overview

Northchess consists of two main components:

1. **Frontend (This Repository)**: A Flutter-based mobile application that handles the game logic, user interface, and player interactions.
2. **Backend**: A Dart-based server that manages real-time updates and multiplayer functionality. ([Backend Repository](https://github.com/baberlabs/nc_abcs_boardgame_backend))

## Features

-   Full chess gameplay, including special moves like En Passant and Castling
-   Multiple game variants: Classic, Edge Wrap, Horde, and Endgame
-   Real-time board updates
-   Pawn promotion
-   Checkmate and stalemate detection
-   Online multiplayer and offline practice mode
-   Clean, modern interface with high-quality chess pieces

## Tech Stack

-   **Language**: Dart
-   **Framework**: Flutter
-   **Key Packages**:
    -   `flutter_svg`: For displaying chess pieces
    -   `web_socket_channel`: For real-time communication with the backend

## Getting Started

### Prerequisites

-   Flutter SDK (latest stable version)
-   Dart SDK (latest stable version)
-   An IDE (Visual Studio Code or Android Studio)
-   Git
-   Backend server running (see [backend repository](https://github.com/baberlabs/nc_abcs_boardgame_backend) for setup instructions)

### Installation

1. Clone the repository:
    ```bash
    $ git clone https://github.com/henryloach/nc_abcs_boardgame_frontend
    ```
2. Navigate to the project folder:
    ```bash
    $ cd northchess-frontend
    ```
3. Install dependencies:
    ```bash
    $ flutter pub get
    ```

### Running the App

1. Ensure the backend server is running for multiplayer functionality.
2. Connect a device or start an emulator.
3. Run the app:
    ```bash
    $ flutter run
    ```

For more details, see the [Flutter setup guide](https://flutter.dev/docs/get-started/install).

## Game Variants

-   **Classic**: Traditional chess rules
-   **Edge Wrap**: Pieces can move across board edges
-   **Horde**: White starts with extra pawns
-   **Endgame**: Limited pieces from the start

## Architecture

-   **Frontend (This Repository)**:
    -   Implements all game logic and state management
    -   Handles user interactions and game moves
    -   Communicates with the backend for multiplayer functionality
-   **Backend**:
    -   Manages WebSocket connections for real-time updates
    -   Handles player matchmaking and game session management
    -   Relays move information between players in multiplayer games

## Meet the Team

-   [Christian Loach](https://github.com/henryloach)
-   [Baber Khan](https://github.com/baberlabs)
-   [Ahmad Mustaffar](https://github.com/amustaffar)
-   [Svitlana Horodylova](https://github.com/horodylova)

## Contributing

We welcome contributions to both the frontend and backend! Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

Ensure your code adheres to our coding standards and include tests for new features.

## License

This project is licensed under the MIT License.

## About Northcoders Bootcamp

This project was created during the 13-week Northcoders Software Development Bootcamp. The program focuses on full-stack development and provides 480 contact hours of training. While the bootcamp primarily teaches JavaScript, we applied our skills to build this Flutter/Dart application with a complementary backend.

For more information, visit the [Northcoders Website](https://northcoders.com/our-courses/coding-bootcamp).

---

Thank you for your interest in **Northchess**. If you have any questions or feedback, please open an issue on this repository. Enjoy playing! ♟️
