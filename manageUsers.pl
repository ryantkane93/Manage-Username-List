#!/usr/bin/perl
use warnings;
use strict;

#-------------All Subroutines------------#

#-----BEGIN displayMenu-----#
sub displayMenu{
my $choice; #Declare the variable that will hold the user's selection from the menu.
print"\nMENU\n=========================\n";
print"(p, P) Print all user info\n\n";
print"(a, A) Add a new user\n\n";
print"(s, S) Search user\n\n";
print"(d, D) Delete user\n\n";
print"(x, X) Exit the menu\n\n\n";
print"Please enter an option: ";
chomp($choice = <STDIN>); #Get the choice from the user so that they can be redirected to another subroutine.

$choice =~ s/([a-zA-Z])/\U$1/i; #Check for the first character in the user's input and then convert it to a capital letter. Canot use \w since it matches numbers and underscore.

if($choice eq 'P'){
&printAll(&readFile());
&displayMenu();
}

elsif($choice eq 'A'){
&add();
&displayMenu();
} 

elsif($choice eq 'S'){
&search(&readFile); 
&displayMenu();
}

elsif($choice eq 'D'){
&delete(&readFile);
&displayMenu();
}

elsif($choice eq 'X'){
exit 2; #Exit the script if the user enters X. Pass a non-zero value so that it identifies as a success.
}

else{ #The user has entered an incorrect choice.
print"You have entered an incorrect choice. Please enter a valid letter option from the menu.\n";
&displayMenu(); #Recall the menu subroutine so that the users can see the options again.
}#End else statement

}#End the displayMenu suboroutine.
#-----END displayMenu-----#



#-----BEGIN openFile-----#

sub openFile{
if(!-e $ARGV[0]){ #If the file does not exist.
open FH, '>>', $ARGV[0] or die "Error: $!"; #Create one by using the append function.
close FH; #Close the filehandler once the file is added.
} #End if
} #End subroutine

#-----END openFile-----#



#-----BEGIN readFile-----#

#This subroutine copies the contents of the file, stores it in an array and then returns it.
sub readFile{
open USERS, '<', $ARGV[0];
my @lines = <USERS>; #Assign all lines in the file to an array.
close USERS;
return @lines;
}

#-----END readFile-----#



#-----BEGIN formatPrint-----#

#When given an array, it will remove the colons between each entry and then output it neatly to the standard output.
sub formatPrint{
foreach(@_){ #While there is still an entry in the array.
chomp; #Remove the newline character.
my @info = split /:/,$_; #Remove the colon between each entry in the file and store it in an array.
#Use printf so that the space between each column can be formatted.
printf "\n%-15s %-15s %s\n", $info[2], $info[0], $info[1];
#15 characters leaves room for longer names that may be entered.
} #End foreach
} #End formatPrint subroutine

#-----END formatPrint-----#



#-----BEGIN printAll-----#
sub printAll{
if(!@_){ #If the file is empty...
print"\nThere are no users to print, please add a user and try again!\n"; #Display a message for the user.
}

else{ #There is information in the file
my %userSort; #Declare a hash that will hold the user's name and username so that it can be sorted properly for output. 
foreach(@_){ #For each string in the file..
my @temp =  split/:/,$_; #Split the first name,last name and username from the rest of the string.
my $fullName = join(':', $temp[0], $temp[1]); #Join together the first name and last name  with a colon so that they can remain together.
$userSort{$temp[2]} = $fullName; #Store the username as the key and the name as the value.
}
#Sort the usernames, rejoin the keys and values with a colon and place them in an  array so that the formatPrint subroutine can be used.
my @lines; #This array will be passed to the printFormat functiion for output.
foreach(sort keys %userSort){
my $line = join (':', $userSort{$_}, $_); #Join the name and username back together after the usernames are sorted.
push @lines, $line;
} #End foreach
&formatPrint(@lines); #Pass the array to the function for output.
} #End else statement
} #End print
#-----END printUsers-----#





#-----BEGIN add-----#

sub add{
my @name; #Declare an array that can be used to store the user's information for easy conversion to capital letters and writing to the file.

print"\nPlease enter the first name of the user being added: ";
chomp(my $first = <STDIN>);
push @name,$first; #Add the first name as the first element of the array.

print"\nPlease enter the last name of the user being added: ";
chomp(my $last = <STDIN>);
push @name,$last; #Add the last name as the second element in the array. 

$first =~ m/[a-zA-Z]/; #Match the first letter in the first name.
my $firstInitial = $&; #Assign the captured variable to a new one.

$last =~ m/[a-zA-Z]{2,4}/; #Match the first four letters of the last name. Assume that a name must have a minimum of two chracters.
my $lastLetters = $&; #Assign the two to four captured letters to a variable.

push @name, $firstInitial . $lastLetters; #Concactenate the username and then add the username to the names array.

my $num1s = &numMatches($name[2]); #Check the number of times the username exists (if it all).

if($num1s > 0){
$name[2] = $name[2] .( "1" x $num1s); #Add the necessary number of 1's to the username.
}

$" = ':'; #Each element of the array will be separated  by a colon when printed to the file.

open USERAPPEND, '>>', $ARGV[0]; #Open the file for appending.
print USERAPPEND uc "@name\n"; #Use uc to covert all letters to capital and then add the entry to the file.
print "\n$first $last successfully added!\n"; #Output a success message once it is added.
close USERAPPEND; #Close the appending filehandler.
}

#-----END add-----


#-----BEGIN numMatches-----#
#This subroutine finds the number of instances that a username occurs in the file (passed as a parameter).
sub numMatches{
my $count = 0; #Declare a variable that will hold the number of times a username is found.

my @lines = &readFile();

my $userName = $_[0];

foreach(@lines){ #for each line in the file...
chomp;
$count +=  s/$userName//gi; #Iterate count by 1 each time the username is found in the file.
} #End foreach
return $count;
}#end numMatch subroutine
#-----END numMatches-----#



#-----BEGIN search-----#
#When given an array of file entries, it will search the file for matches and then redirect it for output.
sub search{
if(!@_){ #If the file is empty...
print"\nThere are no users to search for, please add a user and try again!\n"; #Display a message for the user.
}

else{ #There is information in the file
#Takes a first name as an argument and then searches the file for all entries containing that first name.
print"\nPlease enter the first name you wish to search for: ";
chomp(my $first = <STDIN>); #Make a $first variable that shows the name exactly typed by the user so that they can be reminded of the exact string they used to search when given the results. 
my $firstName = uc $first; #Convert the user's input to uppercase so that it can be easily compared to the file contents.

my @matches; #An array that will store all of the entries that match the search parameter. This is needed in the event that there is more than one match.

foreach(@_){ #While there is still an entry in the array containing the file.
	if($_ =~ m/\A$firstName:/i){ #Compare the first name of each line with the first name entered by the user. #Use i to match any capitalization in the event that a user writes names into the file manually. Use : to avoid an empty string matching everything.
	push @matches, $_; #Add the line to the array if it matches the requested first name.
	}
} #End foreach

if(!@matches) #If there are no elements in the array
{
print"\nThere are no users with the first name $first\n";
} #End if

else{ #There was at least one match found.
print"\nThe following users have the first name $first: ";	
&formatPrint(@matches); #Pass matches to the print function.
} #End second else
} #End first else
}#End search subroutine
#-----END search-----#



#-----BEGIN delete-----#
sub delete{
if(!@_){ #If the file is empty...
print"\nThere are no users to delete, add a user and try again\n!"; #Display a message for the user.
}

else{ #There is information in the file

#When given an array of file entries, it will delete all user information that contains the first and last name.
open USEROUT, '>', $ARGV[0]; #Open the file so that it can be overwritten.

print"Please enter the first name of the user(s) you wish to delete: ";
chomp(my $firstName = uc  <STDIN>); #Store firstName in its own variable for output. Capitalize the input so that it can be compared to the file.

foreach(@_){ #Foreach element in the file...
#Write every record to the file except for the one's that match the name given by the user.
print USEROUT uc $_ unless ($_ =~ m/\A$firstName:/i); #Use the anchor to assure that the first name matches the first name stored in a line. #Use i to match any capitalization in the event that a user writes names into the file manually.Include the : to avoid a blank character deleting every string.
} #end Foreach
close USEROUT; #Close the filehandle after wrtiting to it.
print"All users with the first name $firstName have been removed!";
} #End else statement
} #end delete subroutine

#-----END delete-----#



#-------Main Program-----------#
&openFile(); #Check if the specified file exists, and if not, creates it.
&displayMenu(); #Display the menu and process the user's choices until they exit.

