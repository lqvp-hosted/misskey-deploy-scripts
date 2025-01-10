# Misskey Deployment Scripts

This repository contains scripts to automate the deployment of Misskey instances. It supports multiple repositories and branches, and sends notifications to Discord.

## Features

- **Automatic Git Pull**: Fetches and pulls updates from the specified branch.
- **Discord Notifications**: Sends deployment status updates to Discord.
- **Logging**: Logs all actions to a file for debugging.

## Directory Structure

```
misskey-deploy-scripts/
├── scripts/
│   ├── config.sh
│   ├── deploy_functions.sh
│   ├── deploy_misskey.sh
│   └── deploy_temp.sh
├── logs/
│   ├── misskey/
│   └── misskey-temp/
├── README.md
└── .gitignore
```

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/lqvp-hosted/misskey-deploy-scripts.git
   cd misskey-deploy-scripts
   ```

2. Configure the scripts:
   - Update `scripts/deploy_misskey.sh` and `scripts/deploy_temp.sh` with your Discord webhook URLs and repository paths.

3. Make the scripts executable:
   ```bash
   chmod +x scripts/deploy_misskey.sh
   chmod +x scripts/deploy_temp.sh
   chmod +x scripts/deploy_fuctions.sh
   ```

4. Run the scripts manually or set up a cron job:
   ```bash
   bash scripts/deploy_misskey.sh
   bash scripts/deploy_temp.sh
   ```

## Cron Job Example

Add the following lines to your crontab (`crontab -e`):

```bash
# Misskey: Every 5 minutes
*/5 * * * * /bin/bash /path/to/misskey-deploy-scripts/scripts/deploy_misskey.sh

# Misskey Temp: Every 1 minute
* * * * * /bin/bash /path/to/misskey-deploy-scripts/scripts/deploy_temp.sh
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.