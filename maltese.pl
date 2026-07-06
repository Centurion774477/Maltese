# Maltese
use strict; use warnings;
use feature 'say';
use JSON::Tiny;
# CLI based, concise version coming later

# Maltese is MacOS oriented

my $saveFile = path(malteseSave.jsonl);
my $data = {};
sub create {
    GETNAME:
    say "What would you like to name this package?";
    my $nameGiven = <STDIN>; chomp($nameGiven);
    say "Confirm name:" . $nameGiven . "Type Y to approve; anything else will disapprove";
    my $got = <STDIN>; chomp($got);
    goto GETNAME unless $got eq "Y";

    $data->{packageName} = $nameGiven; # its a bit unsafe but faster
    $data->{scripts} = [];
    say "Package successfully created. Remember to save before closing Maltese.";
}

sub add {
    GETNAME:
    say "Start by naming this script; maybe something like 'brewElixir'?";
    my $scriptName = <STDIN>;
    say "Confirm name:" . $scriptName . "Type Y to approve; anything else will disapprove.";
    my $got = <STDIN>; chomp($got); goto GETNAME unless $got eq "Y";

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
    @scriptArray # each value is an individual script
    while (my $input = <STDIN>) {
        $index += 1;
        chomp($input);
        push($input), @scriptArray;
        last if $input eq 'END';
        if ($index > 19) {
            say "You forgot your 'END'. Here's another try.";
            redo;
        }
    }
    my sub parseScripts {
        for my $script (@scriptArray) {
            # brew -> brew install elixir
            if ($script =~ /(?<header>\w)\s+->\s+(?<content>.)/) { # Nesting!!!
                my $hash = {scriptName => $+{header}, scriptBody => $+{content}};
                push($data->{scripts}), $hash;
            }
            else {
                die 'Invalid script found:' . $script
                # maybe make a better error check later
            }
        }
    }
}

sub save {
    # push the temporary $data object to jsonl (or something else) then clear it
    my $count = 0;
    $count = @{$data->{scripts}};
    if ($count == 0) {die 'You cannot save right now --you havent given Maltese any scripts.'};
    $saveFile->append(encode_json($data->{scripts}) . "\n");
    $data->{scripts} = [];
    
    say "Your package has been saved."
}

sub readSave {
    say "reading!";
    my @scripts = map {decode_json($_)};
}

sub compile {
    say "compiling!";
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
    ";
    my $input = <STDIN>;
    my @options = qw[1 2 3]
    unless ($input ~~ @options) {
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
    else {
        say 'invalid input'; redo; # this won't work, will it? Since it's in its own nest
    }
}

