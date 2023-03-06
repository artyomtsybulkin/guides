# A shell script needs to be saved with the extension .sh.
# The file needs to begin with the shebang line (#\!) to let the Linux system
# know which interpreter to use for the shell script.
# -----------------------------------------------------------------------------
# For environments that support bash, use:
#!/bin/bash

# For environments that support shell, use:
#!/bin/sh

# Finally, you can run the script with the following command:
bash basic_script.sh

# You can also run a script without specifying bash:
./basic_script.sh

# Running the file this way might require the user to give permission first.
# Running it with bash doesn’t require this permission.
chmod +x basic_script.sh

# Scripts can include user-defined variables. In fact, as scripts get larger in
# size, it is essential to have variables that are clearly defined and that have
# self-descriptive names.
#!/bin/bash
# This is a comment
# defining a variable
GREETINGS="Hello! How are you"
echo $GREETINGS

# Shell scripts can be made interactive with the ability to accept input from
# the command line. You can use the read command to store the command line input
# in a variable.
#!/bin/bash
# This is a comment
# defining a variable
echo "What is your name?"
# reading input
read NAME
# defining a variable
GREETINGS="Hello! How are you"
echo $NAME $GREETINGS

# Users can define their own functions in a script. These functions can take
# multiple arguments.
#!/bin/bash
#This is a comment
# defining a variable
echo "What is the name of the directory you want to create?"
# reading input 
read NAME
echo "Creating $NAME ..."
mkcd ()
{
  mkdir "$NAME" 
  cd "$NAME"
}
mkcd
echo "You are now in $NAME"