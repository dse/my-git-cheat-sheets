#!/usr/bin/perl
use warnings;
use strict;
use open IO => ":locale";
use JSON;
use Text::Wrap;

my $commands = decode_json_file("commands.json");
my $locations = decode_json_file("locations.json");
my $translations = decode_json_file("translations.json");

my $column_width = 26;
my $location_separator = "|";
my $location_index_of = { map { ($locations->[$_] => $_) } (0 .. $#$locations) };

my $line_template =
  $location_separator .
  join($location_separator, map { " " x ($column_width - 1) } @$locations) .
  $location_separator;

my $header_line =
  $location_separator .
  join($location_separator, map { sprintf("%-*s", $column_width - 1, $_) }
	 @$locations) .
  $location_separator;

print "$header_line\n";
print "$line_template\n";

my $index = 0;
foreach my $command (@$commands) {
    $command->{index} = $index++;
    if ($command->{left} eq "stash" ||
	  $command->{right} eq "stash") {
	$command->{is_stash} = 1;
    }
    elsif ($command->{right} eq "remote_repo" ||
	     $command->{left} eq "remote_repo") {
	$command->{is_remote_repo} = 1;
    }
    $command->{left_index} = $location_index_of->{$command->{left}};
    $command->{right_index} = $location_index_of->{$command->{right}};
}

@$commands = sort { $a->{is_remote_repo} <=> $b->{is_remote_repo}
		      ||
		      $a->{is_stash} <=> $b->{is_stash}
		      ||
		      $a->{left_index} <=> $b->{left_index}
		      ||
		      $a->{right_index} <=> $b->{right_index}
		      ||
		      $a->{index} <=> $b->{index} } @$commands;

foreach my $command (@$commands) {
    my $left = $command->{left};
    my $right = $command->{right};
    my $direction = $command->{direction};
    my $key = $command->{key};
    my $tags = $command->{tags};

    my $cmd  = $translations->{en}->{commands}->{$key}->{cmd};
    my $docs = $translations->{en}->{commands}->{$key}->{docs};

    my $start = 2                 + $location_index_of->{$left} * $column_width;
    my $end   = $column_width - 1 + $location_index_of->{$right} * $column_width;

    my $columns = $end - $start - 4;

    local $Text::Wrap::columns = $columns;
    my $lines = Text::Wrap::wrap("", "  ", $cmd);

    my @lines = split("\n", $lines);
    @lines = map { sprintf("| %-*.*s |", $columns, $columns, $_) } @lines;

    my $top    = "+" . ("-" x ($end - $start - 2)) . "+";
    my $bottom = "+" . ("-" x ($end - $start - 2)) . "+";

    foreach ($top, @lines, $bottom) {
	if ($direction eq "dn") {
	    substr($_, 0, 1) = "<";
	}
	if ($direction eq "up") {
	    substr($_, length($_) - 1, 1) = ">";
	}

	my $line = $line_template;
	substr($line, $start, length($_)) = $_;
	print("$line\n");
    }
}

sub decode_json_file {
    my ($filename) = @_;
    local $/;
    my $fh;
    open($fh, "<", $filename) or return;
    warn("$filename\n");
    binmode($fh);
    my $json_text = <$fh>;
    return decode_json($json_text, { utf8 => 1,
				     allow_singlequote => 1 });
}

