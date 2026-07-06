# Maltese
use strict; use warnings;
use feature 'say';
use JSON::Tiny;
use Path::Tiny;

# CLI based, concise version coming later

# Maltese is MacOS oriented

my $saveFile = path("malteseSave.jsonl");
my $userFile = path("malteseUser.pl");
my $data = {};
sub create {
    GETNAME:
    say "What would you like to name this package?";
    my $nameGiven = <STDIN>; chomp($nameGiven);
    say "Confirm name:" . $nameGiven . "Type Y to approve; anything else will disapprove";
    my $got = <STDIN>; chomp($got);
    goto GETNAME unless $got eq "Y";

    $data->{packageName} = $nameGiven;
    $data->{scripts} = [];
    say "Package successfully created. Remember to save before closing Maltese.";
}

# argue @scriptArray as... an array of scripts? Shocker. . .
sub parseScripts {
        for my $script (@scriptArray) {
            # brew -> brew install elixir
            if ($script =~ /(?<header>\w+)\s+->\s+(?<content>.+/) {
                my $hash = {scriptName => $+{header}, scriptBody => $+{content}};
                if ($+{header} =~ /sudo/) {
                    die 'Sorry, but Maltese does not allow sudo commands.'; # eventually, add more validation beyond the sudo checker
                }
                push($data->{scripts}), $hash;
            }
            else {
                die 'Invalid script found:' . $script
                # maybe make a better error check later
            }
        }
}

sub add {
    GETNAME:
    say "Start by naming this script; maybe something like 'brewElixir'?";
    chomp(my $scriptName = <STDIN>;)
    say "Confirm name:" . $scriptName . "Type Y to approve; anything else will disapprove.";
    chomp(my $got = <STDIN>); goto GETNAME unless $got eq "Y";

    say "
    Now provide your scripts.
    Example:
    brew -> brew install elixir
    curl -> curl -fsSO https://elixir-lang.org/install.sh
    In other words:
    - use a keyword then the script
    - only use one line per script
    - end with 'END'
    ";
    my $index = 0;
    my @scriptArray # each value is an individual script
    while (my $input = <STDIN>) {
        $index += 1;
        chomp($input);
        push @scriptArray, $input;
        last if $input eq 'END';
        if ($index > 19) {
            say "You forgot your 'END'. Here's another try.";
            redo;
        }
    }
    parseScripts()
}

sub save {
    # push the temporary $data object to jsonl (or something else) then clear it
    my $count = 0;
    $count = @{$data->{scripts}};
    if ($count == 0) {die 'You cannot save because you havent given Maltese any scripts.'};
    $saveFile->append(encode_json($data->{scripts}) . "\n");
    $data->{scripts} = [];
    say "Your package has been saved.";
}

sub readSave {
    # I have no fucking clue how to parse JSON
    my @scripts = map {decode_json($_)} $saveFile->lines({chomp => 1});
    die 'You dont have any scripts for this project' if (scalar @{data->{scripts}} == 0); # Trying to check for an empty array
    for my $script (@scripts) {
        push@{$data->{scripts}}, $script;
    }
    say "Successfully restored your previous session.";
}

# I don't literally want to compile the entire Maltese project; we only need a reader version.
# I'll probably just finalize the data in jsonl, then package that with a lightweight script.
# Either way: get the output working and the user side can be ANYTHING
# if this doesn't work I'll just compile the full Maltese file.
sub compile {
    unless (defined $data->{packageName}) {
        die 'Please define a project before compiling'
    }
    say "compiling!";
    say "Confirm: You are about to pack your scripts for" . $data->{packageName} . "Are you sure? Y/N";
    chomp(my $gets = <STDIN>);
    $gets eq 'Y' ? say 'compiling . . .' : say 'Abandoning the compilation process' && return;
    if ($gets eq 'Y') {
        say 'compiling . . .';
    } else {
        say 'Abandoning the compilation process';
        return;
    }
    # now we have to run some scripts
    # first, package the jsonl and malteseUser.pl files into a single directory
    
}

# this really doesn't need to be a function but it's cleaner this way
sub exit {
    say "exiting!";
}

do {
    print "
    Welcome to Maltese!
    Enter a number corresponding to an option:
    1 -> Create a package
    2 -> Add scripts to a package
    3 -> Compile a package
    4 -> Save package without compiling
    5 -> Pick back up from a save
    6 -> Exit Maltese
    ";
    chomp(my $input = <STDIN>);
    my @options = qw[1 2 3]
    unless (grep {$_ eq $input} @options)) {
        say 'Invalid input; only enter 1, 2, or 3.';
        redo;
    }
    if ($input eq '1') {
        create();
    }
    elsif ($input eq '2') {
        add();
    }
    elsif ($input eq '3') {
        compile();
    }
    elsif ($input eq '4') {
        save();
    }
    elsif ($input eq '5') {
        readSave();
    }
    elsif ($input eq '6') {
        exit();
    }
    else {
        say 'invalid input';
        continue;
    }
} while (1)

