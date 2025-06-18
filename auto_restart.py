#!/usr/bin/env python3
import subprocess
import time
import signal
import sys
import os
from datetime import datetime

class BotManager:
    def __init__(self):
        self.bot_process = None
        self.restart_interval = 6 * 60 * 60  # 6 jam dalam detik
        self.check_interval = 30  # Check setiap 30 detik
        self.running = True
        
        # Setup signal handlers
        signal.signal(signal.SIGTERM, self.signal_handler)
        signal.signal(signal.SIGINT, self.signal_handler)
    
    def log(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_message = f"[{timestamp}] {message}"
        print(log_message)
        
        # Write to log file
        with open("bot_manager.log", "a") as f:
            f.write(log_message + "\n")
    
    def start_bot(self):
        """Start the bot process"""
        try:
            # Kill existing bot processes
            try:
                subprocess.run(["pkill", "-f", "python.*AnonXMusic"], check=False)
                time.sleep(2)
            except:
                pass
            
            self.log("Starting AnonXMusic bot...")
            
            # Start bot
            self.bot_process = subprocess.Popen(
                [sys.executable, "-m", "AnonXMusic"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Wait a bit to see if it starts successfully
            time.sleep(5)
            
            if self.bot_process.poll() is None:
                self.log(f"Bot started successfully with PID {self.bot_process.pid}")
                return True
            else:
                self.log("Bot failed to start!")
                return False
                
        except Exception as e:
            self.log(f"Error starting bot: {e}")
            return False
    
    def stop_bot(self):
        """Stop the bot process"""
        if self.bot_process and self.bot_process.poll() is None:
            self.log(f"Stopping bot process {self.bot_process.pid}")
            self.bot_process.terminate()
            
            # Wait for graceful shutdown
            try:
                self.bot_process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                self.log("Bot didn't shutdown gracefully, force killing...")
                self.bot_process.kill()
                self.bot_process.wait()
            
            self.log("Bot stopped")
    
    def is_bot_running(self):
        """Check if bot is still running"""
        if self.bot_process is None:
            return False
        
        return self.bot_process.poll() is None
    
    def restart_bot(self):
        """Restart the bot"""
        self.log("=== RESTARTING BOT ===")
        self.stop_bot()
        time.sleep(2)
        return self.start_bot()
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        self.log(f"Received signal {signum}, shutting down...")
        self.running = False
        self.stop_bot()
        sys.exit(0)
    
    def run(self):
        """Main loop"""
        self.log("=== AnonXMusic Bot Manager Started ===")
        self.log(f"Restart interval: {self.restart_interval} seconds")
        self.log(f"Check interval: {self.check_interval} seconds")
        
        # Start bot initially
        if not self.start_bot():
            self.log("Failed to start bot initially, exiting...")
            return
        
        last_restart = time.time()
        
        while self.running:
            try:
                # Check if bot is still running
                if not self.is_bot_running():
                    self.log("Bot died! Restarting...")
                    if self.start_bot():
                        last_restart = time.time()
                    else:
                        self.log("Failed to restart bot, will try again in 60 seconds...")
                        time.sleep(60)
                        continue
                
                # Check if it's time for scheduled restart
                current_time = time.time()
                if current_time - last_restart >= self.restart_interval:
                    self.log("Scheduled restart time reached")
                    if self.restart_bot():
                        last_restart = current_time
                    else:
                        self.log("Scheduled restart failed, will try again later...")
                
                # Sleep and show status
                time.sleep(self.check_interval)
                
                # Show status every 5 minutes
                if int(current_time) % 300 == 0:
                    remaining = self.restart_interval - (current_time - last_restart)
                    hours = int(remaining // 3600)
                    minutes = int((remaining % 3600) // 60)
                    self.log(f"Bot status: OK. Next restart in {hours}h {minutes}m")
                
            except KeyboardInterrupt:
                break
            except Exception as e:
                self.log(f"Error in main loop: {e}")
                time.sleep(60)
        
        self.log("Bot manager shutting down...")
        self.stop_bot()

if __name__ == "__main__":
    manager = BotManager()
    manager.run()