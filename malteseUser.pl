#!/usr/bin/perl

use strict; use warnings;
use feature 'say';
use JSON::Tiny;
use Path::Tiny;


my $scriptFile = path("malteseSave.jsonl");
unless (-e $scriptFile) {
    die '
    FAIL: A critical error occured while Maltese packaged this project.
    Please notify the owner of this project.
    ';
}

my @scriptArray = map {decode_json($_)} ($scriptFile->lines{chomp => 1});

# receive the jsonl file,
# parse it into an array,
# iterate through each script, providing options for each one.

my $scriptMessage = "
    What would you like to do?
    1 -> Have Maltese install for you
    2 -> Manually execute it yourself
    3 -> Skip this dependency
    4 -> revisit skipped dependencies
";

my $revisitMessage = "
    What would you like to do?
    1 -> Have Maltese install for you
    2 -> Manually execute it yourself
    3 -> Forget this dependency (unable to revisit)
";

my $skippedDependencies = [];

# argue $scriptLogic
sub executeDependency {
    my $scriptLogic = shift;
    say 'Executing script . . .';
    system($scriptLogic);
    say '✓ -> Successfully executed script';
}

# just to clean up the revisit skips logic
# argue the input and scriptlogic
sub reviewInput {
    say "parsing . . .";
    my ($gets, $scriptLogic) = @_;
    
    if ($gets eq '1') {
        executeDependency($scriptLogic);
    } elsif ($gets eq '2') {
        say "Here is the script:\n " . $script . " \n " . "Run it in your terminal.";
    } elsif ($gets eq '3') {
        say 'Forgetting this script.';
        # reject all values that are equal to this script
        $skippedDependencies = grep {$_ ne $scriptLogic} @{$skippedDependencies};
        say '✓ -> dropped!';
    }
    else redo;
}

# argue scriptlogic of the script that was skipped
my $addToPile = sub {
    my $script = shift;
    push @{$skippedDependencies}, $script;
};

# parses input, and does what it needs to do.
# argue the name of the script (just to give better responses)
sub procedure {
    my $script = shift;
    my $nameOfScript = $script->{scriptName};
    my $scriptLogic = $script->{scriptBody};
    do {
        say $scriptMessage;
        chomp(my $input = <STDIN>);
        if ($input eq '1') { # auto install
            say 'Are you sure you want Maltese to automatically install this script? It cannot guarantee safety. Y/N?';
            chomp(my $input = <STDIN>);
            if ($input eq 'N') {
                say 'Understood, skipping this dependency.'; $addToPile->($scriptLogic);
                return;
            }
            say 'executing ' . $scriptLogic;
            # call a function
        } elsif ($input eq '2') { # manual install
            say "Here is the script:\n " . $script . " \n " . "Run it in your terminal.";
        } elsif ($input eq '3') { # skip this dependency
            say 'Got it. Skipping ' . $nameOfScript . ' If you regret this decision, you can revisit it later.';
            $addToPile->($scriptLogic);
        } elsif ($input eq '4') { # revisit skipped dependencies
            if (scalar @{$skippedDependencies} == 0) {
                say "You haven't skipped any dependencies yet; You can only run this after skipping.";
                return;
            }
            for my $skippedScript @{$scriptMessage} {
                say "Name of skipped script: " . $skippedScript->{scriptName} . "\nContents: "
                . $skippedScript->{script};
                say $revisitMessage;
                chomp(my $gets = <STDIN>);
                reviewInput($gets, $scriptLogic); # check which option they chose then execute it
            }
        }
    } while (1)
}

say 'Welcome to Maltese!';

# remember to parse the jsonl into @scriptArray
for my $script (@scriptArray) {
    procedure($script);
}