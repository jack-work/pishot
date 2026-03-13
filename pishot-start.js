#!/usr/bin/env node
import { spawn, execSync } from "node:child_process";
import { existsSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import puppeteer from "puppeteer-core";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
	console.log("Usage: pishot-start.js [--profile]");
	console.log("\nOptions:");
	console.log("  --profile  Copy your default Firefox profile (cookies, logins)");
	console.log("\nExamples:");
	console.log("  pishot-start.js            # Start with fresh profile");
	console.log("  pishot-start.js --profile  # Start with your Firefox profile");
	process.exit(1);
}

const cacheDir = join(homedir(), ".cache", "pishot");
const profileDir = join(cacheDir, "firefox-profile");

// Kill existing Firefox remote debugging instances on port 9222
try {
	execSync("pkill -f 'firefox.*remote-debugging-port.*9222'", { stdio: "ignore" });
	await new Promise((r) => setTimeout(r, 1000));
} catch {}

mkdirSync(cacheDir, { recursive: true });

if (useProfile) {
	// Find the default Firefox profile
	const profilesDir = join(homedir(), ".mozilla", "firefox");
	if (existsSync(profilesDir)) {
		try {
			const profileIni = execSync(`grep -A1 '\\[Install' "${profilesDir}/profiles.ini"`, {
				encoding: "utf-8",
			});
			const defaultMatch = profileIni.match(/Default=(.+)/);
			if (defaultMatch) {
				const srcProfile = join(profilesDir, defaultMatch[1]);
				console.log(`Syncing profile from ${srcProfile}...`);
				execSync(`rsync -a --delete "${srcProfile}/" "${profileDir}/"`, { stdio: "pipe" });
				// Remove lock files that prevent starting
				try {
					execSync(`rm -f "${profileDir}/lock" "${profileDir}/.parentlock"`, { stdio: "ignore" });
				} catch {}
			}
		} catch (e) {
			console.error("Warning: Could not sync profile, starting fresh");
		}
	}
}

const firefoxArgs = [
	"--remote-debugging-port=9222",
	"--no-remote",
];

if (useProfile && existsSync(profileDir)) {
	firefoxArgs.push("--profile", profileDir);
} else {
	firefoxArgs.push("--profile", join(cacheDir, "fresh-profile"));
}

// Start Firefox detached
spawn("firefox", firefoxArgs, {
	detached: true,
	stdio: "ignore",
}).unref();

// Wait for Firefox to be ready
let connected = false;
for (let i = 0; i < 30; i++) {
	try {
		const browser = await puppeteer.connect({
			browserURL: "http://localhost:9222",
			defaultViewport: null,
		});
		await browser.disconnect();
		connected = true;
		break;
	} catch {
		await new Promise((r) => setTimeout(r, 500));
	}
}

if (!connected) {
	console.error("Failed to connect to Firefox on :9222");
	process.exit(1);
}

console.log(`Firefox started on :9222${useProfile ? " with your profile" : ""}`);
