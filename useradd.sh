#!/bin/bash

# Check if userlist.txt exists
if [[ ! -f userlist.txt ]]; then
  echo "Error: userlist.txt not found!"
  exit 1
fi

# Step 1: Create users from userlist.txt
while read -r username; do
  if id "$username" &>/dev/null; then
    echo "User '$username' already exists. Skipping..."
  else
    useradd -m "$username"
    echo "User '$username' created."
  fi
done < userlist.txt

# Step 2: Create group 'sysadmins' if it doesn't exist
if getent group sysadmins > /dev/null; then
  echo "Group 'sysadmins' already exists. Skipping..."
else
  groupadd sysadmins
  echo "Group 'sysadmins' created."
fi

# Step 3: Add users to 'sysadmins' group
while read -r username; do
  usermod -aG sysadmins "$username"
  echo "User '$username' added to 'sysadmins' group."
done < userlist.txt

# Step 4: Create directory and assign group ownership
mkdir -p /home/ec2-user/managers
chown :sysadmins /home/ec2-user/managers
chmod 770 /home/ec2-user/managers
echo "Directory '/home/ec2-user/managers' created and group ownership set to 'sysadmins'."

# Step 5: Ensure sysadmins group can create files there
chmod g+rwx /home/ec2-user/managers
echo "'sysadmins' group now has read/write/execute permissions in '/home/ec2-user/managers'."

echo "All tasks completed successfully."

