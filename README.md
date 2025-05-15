# cloudflare_dyndns

This is a simple Bash script that automatically updates a Cloudflare A record if your public IP address changes. It's useful for setups with a dynamic IP (e.g. home servers, self-hosted services).

## 🔧 How It Works

The script checks your current public IP address via [`ipify`](https://www.ipify.org/) and compares it to the IP stored in your Cloudflare DNS A record. If the addresses differ, it updates the DNS record using the Cloudflare API.

## 📄 Configuration

The script expects a plain text configuration file as its first argument, with the following format:

```txt
<API_TOKEN>
<ZONE_ID>
<RECORD_NAME>
<RECORD_ID>
```
## 🚀 Usage

./dyndns.sh config.txt
