# Mailbox System for RedM

This project introduces a fully integrated mailbox system for RedM servers, leveraging the capabilities of VORP and FeatherMenu. It's designed to enhance in-game communication by allowing players to send and receive messages through personalized mailboxes.

## Key Features

- **Mailbox Registration and Management:** Players can register their own mailboxes within the game.
- **In-Game Messaging:** Enables sending and receiving messages directly through the mailboxes.
- **Integration with VORP and FeatherMenu:** Seamlessly works with vorp frameworks and tools.
- **Customizable Mailbox Locations:** Place mailboxes at desired locations across the map.
- **Universal Access:** Players can send messages from any mailbox, provided they have a letter purchased from the shop.

## Prerequisites

Before installing, ensure you have the following resources available on your server:

- VORP Core
- FeatherMenu
- oxmysql
- vorp_inventory

## Installation

Follow these steps to get the mailbox system up and running on your server:

1. **Download the Latest Release**
   - Navigate to the Releases section of this repository and download the latest version.

2. **Configure Server Settings**
   - Add the following line to your `server.cfg` file to ensure the mailbox system is recognized by the server:
     ```plaintext
     ensure isee-mailbox
     ```
   - The database configuration is handled automatically upon server start. The necessary tables and fields will be created and initialized without any additional input required from the user. Ensure your database credentials are correctly set in the server configuration to avoid connection issues.

## Contributing

Contributions are welcome! If you'd like to improve the mailbox system, please consider:

- **Submitting a Pull Request:** Include your enhancements or bug fixes.
- **Opening Issues:** Provide detailed information about bugs or suggest new features.

## Credits

This project was inspired by the innovative approaches found in [fists-GlideMail](https://github.com/Fistsofury/fists-GlideMail). Special thanks to the contributors of that project for their ideas and contributions to the community.

## Support

If you encounter any issues or need help, please open an issue on this repository.

---

**Happy role-playing!**
