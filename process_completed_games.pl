#!/usr/bin/env perl -w

use strict;
use Data::Dumper;
use Text::CSV;

sub calculate_elo {
    my $old_score = shift; # old rating
    my $ratio = shift;     # percentage of weight to give to this score (run vs pass)
    my $kfactor = shift;
    my $win = shift;
    my $we = shift;        # win expectancy

    my $r = $old_score + ($ratio * $kfactor * $win - $we);

    return($r);
}

sub load_games {
    my $filename = shift;

    my @results;

    # watch out the encoding!
    open(my $fh, '<:utf8', $filename)
        or die "Can't open $filename: $!";

    # skip to the header
    my $header = <$fh>;

    my $csv = Text::CSV->new or die "Text::CSV error: " . Text::CSV->error_diag;

    # define column names    
    $csv->parse($header);
    $csv->column_names([$csv->fields]);

    # parse the rest
    while (my $row = $csv->getline_hr($fh)) {
        push(@results, $row);
    }

    $csv->eof or $csv->error_diag;
    close $fh;

    return(\@results);
}

sub ratings_to_hash {
    my $filename = shift;

    my %ratings;

    # watch out the encoding!
    open(my $fh, '<:utf8', $filename)
        or die "Can't open $filename: $!";

    # skip to the header
    my $header = <$fh>;

    my $csv = Text::CSV->new or die "Text::CSV error: " . Text::CSV->error_diag;

    # define column names    
    $csv->parse($header);
    $csv->column_names([$csv->fields]);

    # parse the rest
    while (my $row = $csv->getline_hr($fh)) {
        $ratings{$row->{'Team'}} = { 'RunDef' => $row->{'RunDef'},
                                     'RunOff' => $row->{'RunOff'},
                                     'PassOff' => $row->{'PassOff'},
                                     'PassDef' => $row->{'PassDef'}
                                   };
    }

    $csv->eof or $csv->error_diag;
    close $fh;

    return(\%ratings);
}
my $ratings_file = "ratings.csv";
my $games_file = "games.csv";

# base weight for regular season games
my $base_k = 20;

# home field advantage weight
my $ha = 100;

# read ratings
my $ratings = &ratings_to_hash($ratings_file);

# read games
my $games = &load_games($games_file);

foreach my $g (@$games) {
    # calculate win expectancies
    my $h_p_we = 1 / (10 ^ - (($ratings->{$g->{'Home'}}->{'PassOff'} - $ratings->{$g->{'Away'}}->{'PassDef'} + $ha) / 400) + 1);
    my $a_p_we = 1 / (10 ^ - (($ratings->{$g->{'Away'}}->{'PassOff'} - $ratings->{$g->{'Home'}}->{'PassDef'}) / 400) + 1);
    my $h_r_we = 1 / (10 ^ - (($ratings->{$g->{'Home'}}->{'RunOff'} - $ratings->{$g->{'Away'}}->{'RunDef'} + $ha) / 400) + 1);
    my $a_r_we = 1 / (10 ^ - (($ratings->{$g->{'Away'}}->{'RunOff'} - $ratings->{$g->{'Home'}}->{'RunDef'}) / 400) + 1);
    my $kfactor = (1 + (abs($g->{'HomeScore'} - $g->{'AwayScore'}) % 7) * .25);

    # calculate new home team scores
    $ratings->{$g->{'Home'}}->{'PassOff'} = &calculate_elo($ratings->{$g->{'Home'}}->{'PassOff'},
                                                          $g->{'ExpPassPCT'},
                                                          ($base_k * $kfactor),
                                                          (($g->{'HomeScore'} > $g->{'AwayScore'}) ? 1 : 0),
                                                          $h_p_we);
    $ratings->{$g->{'Home'}}->{'RunOff'} = &calculate_elo($ratings->{$g->{'Home'}}->{'RunOff'},
                                                          (1 - $g->{'ExpPassPCT'}),
                                                          ($base_k * $kfactor),
                                                          (($g->{'HomeScore'} > $g->{'AwayScore'}) ? 1 : 0),
                                                          $h_r_we);
    $ratings->{$g->{'Home'}}->{'PassDef'} = &calculate_elo($ratings->{$g->{'Home'}}->{'PassDef'},
                                                          $g->{'ExpPassPCT'},
                                                          ($base_k * $kfactor),
                                                          (($g->{'HomeScore'} > $g->{'AwayScore'}) ? 1 : 0),
                                                          (1 - $a_p_we));
    $ratings->{$g->{'Home'}}->{'RunDef'} = &calculate_elo($ratings->{$g->{'Home'}}->{'RunDef'},
                                                          (1 - $g->{'ExpPassPCT'}),
                                                          ($base_k * $kfactor),
                                                          (($g->{'HomeScore'} > $g->{'AwayScore'}) ? 1 : 0),
                                                          (1 - $a_r_we));
    # calculate new away team scores 
    $ratings->{$g->{'Away'}}->{'PassOff'} = &calculate_elo($ratings->{$g->{'Away'}}->{'PassOff'},
                                                          $g->{'ExpPassPCT'},
                                                          ($base_k * $kfactor),
                                                          (($g->{'AwayScore'} > $g->{'HomeScore'}) ? 1 : 0),
                                                          $a_p_we);
    $ratings->{$g->{'Away'}}->{'RunOff'} = &calculate_elo($ratings->{$g->{'Away'}}->{'RunOff'},
                                                          (1 - $g->{'ExpPassPCT'}),
                                                          ($base_k * $kfactor),
                                                          (($g->{'AwayScore'} > $g->{'HomeScore'}) ? 1 : 0),
                                                          $a_r_we);
    $ratings->{$g->{'Away'}}->{'PassDef'} = &calculate_elo($ratings->{$g->{'Away'}}->{'PassDef'},
                                                          $g->{'ExpPassPCT'},
                                                          ($base_k * $kfactor),
                                                          (($g->{'AwayScore'} > $g->{'HomeScore'}) ? 1 : 0),
                                                          (1 - $h_p_we));
    $ratings->{$g->{'Away'}}->{'RunDef'} = &calculate_elo($ratings->{$g->{'Away'}}->{'RunDef'},
                                                          (1 - $g->{'ExpPassPCT'}),
                                                          ($base_k * $kfactor),
                                                          (($g->{'AwayScore'} > $g->{'HomeScore'}) ? 1 : 0),
                                                          (1 - $h_r_we));
}

# write out new ratings

exit 0;

