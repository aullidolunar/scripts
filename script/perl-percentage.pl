#!/usr/bin/perl

use warnings;
use utf8;
use strict;
use Gtk2;
use Gtk2::Gdk::Keysyms;
use Glib qw/TRUE FALSE/;
use File::Spec;
use Cwd qw/abs_path/;
use Locale::gettext;
use POSIX;
use Switch;

use constant {
	INCREMENT => 1,
	DECREMENT => 2,
	PERCENTAGE => 3
};

# lapzas message: < >

BEGIN {
	sub _ { gettext (@_); }
}

sub do_calculate {
	my ($pos, $n1, $n2, $resp) = @_;
	my $r = 0.0;
	my $k = (($n1*$n2)/100);
	switch ($pos) {
		case (INCREMENT) {
			$r = $n1 + $k;
		}
		case (DECREMENT) {
			$r = $n1 - $k;
		}
		case PERCENTAGE {
			$r = (100*(($n1 < $n2) ? ($n2-$n1) : ($n2+$n1)))/$n1;
		}
	}
	$resp->set_text(sprintf ("%0.2f", $r));
}

sub toggle_button_ok {
	my ($button1, $entry1, $entry2, $index) = @_;
	my $state = TRUE;
	if ($index) {
		$state = ($entry1->get_text_length && $entry2->get_text_length);
	} else {
		$state = FALSE;
	}
	$button1->set_sensitive ($state);
}

sub show_error_box {
	my ($parent, $header, $body) = @_;
	my $md = Gtk2::MessageDialog->new_with_markup ($parent, 'destroy-with-parent', 'error', 'close', "<b>$header</b>");
	$md->set_title ($parent->get_title);
	$md->format_secondary_markup ($body);
	$md->run;
	$md->destroy;
}

sub on_window1_destroy {
	my ($window, $data) = @_;
	Gtk2->main_quit;
}

sub on_combobox1_changed {
	my ($combobox, $data) = @_;
	my $index = $combobox->get_active;
	$data->{'label3'}->set_text ($index == PERCENTAGE ? _('Value2') : _('Percentage'));
	toggle_button_ok ($data->{'button1'}, $data->{'entry1'}, $data->{'entry2'}, $index);
}

sub on_any_entry_changed {
	my ($entry, $data) = @_;
	my $index = $data->{'combobox1'}->get_active;
	toggle_button_ok ($data->{'button1'}, $data->{'entry1'}, $data->{'entry2'}, $index);
}

sub on_any_entry_press {
	my ($entry, $event, $data) = @_;
	my @valid_keys = (
		$Gtk2::Gdk::Keysyms{Tab},
		$Gtk2::Gdk::Keysyms{BackSpace},
		$Gtk2::Gdk::Keysyms{0},
		$Gtk2::Gdk::Keysyms{1},
		$Gtk2::Gdk::Keysyms{2},
		$Gtk2::Gdk::Keysyms{3},
		$Gtk2::Gdk::Keysyms{4},
		$Gtk2::Gdk::Keysyms{5},
		$Gtk2::Gdk::Keysyms{6},
		$Gtk2::Gdk::Keysyms{7},
		$Gtk2::Gdk::Keysyms{8},
		$Gtk2::Gdk::Keysyms{9},
		$Gtk2::Gdk::Keysyms{KP_0},
		$Gtk2::Gdk::Keysyms{KP_1},
		$Gtk2::Gdk::Keysyms{KP_2},
		$Gtk2::Gdk::Keysyms{KP_3},
		$Gtk2::Gdk::Keysyms{KP_4},
		$Gtk2::Gdk::Keysyms{KP_5},
		$Gtk2::Gdk::Keysyms{KP_6},
		$Gtk2::Gdk::Keysyms{KP_7},
		$Gtk2::Gdk::Keysyms{KP_8},
		$Gtk2::Gdk::Keysyms{KP_9},
		$Gtk2::Gdk::Keysyms{period},
		$Gtk2::Gdk::Keysyms{KP_Decimal},
		$Gtk2::Gdk::Keysyms{KP_Subtract},
		$Gtk2::Gdk::Keysyms{minus}
	);
	switch ($event->keyval) {
		case (\@valid_keys) { return FALSE; }
		else { return TRUE; }
	}
}

sub on_button1_clicked {
	my ($button, $data) = @_;
	my $error_counter = 0;
	my $error_msg = _('The following fields have bogues values:') . "\n";
	my $number2 = $data->{'entry1'}->get_text;
	my $number1 = 0.0;
	if ($number2 !~ m/^[-]?\d+(?:[.]\d+)?$/) {
		$error_counter++;
		$error_msg .= _('Value1') . ": <b>$number2</b>\n";
	}
	$number1 = $number2;
	$number2 = $data->{'entry2'}->get_text;
	if ($number2 !~ m/^[-]?\d+(?:[.]\d+)?$/) {
		$error_counter++;
		$error_msg .= $data->{'label3'}->get_text . ": <b>$number2</b>\n";
	}
	my $index = $data->{'combobox1'}->get_active;
	if ($error_counter) {
		my $model = $data->{'combobox1'}->get_model;
		my $iter = $model->iter_nth_child (undef, $index);
		my $op = $model->get ($iter, 1);
		show_error_box ($data->{'window1'}, _('Error calculating') . ': ' . $op, $error_msg);
	} else {
		do_calculate ($index, $number1, $number2, $data->{'entry3'});
	}
}

sub on_button2_clicked {
	my ($button, $data) = @_;
	Gtk2->show_about_dialog (
		$data->{'window1'},
		'authors', ['Joel Almeida<aullidolunar@gmail.com>'],
		'artists', ['icons: <http://findicons.com/>'],
		'comments', _('Percentage calculator'),
		'logo', $data->{'window1'}->get_icon,
		'program-name', $data->{'p4ck4g3'},
		'translator-credits', 'Español: Joel<aullidolunar@gmail.com>',
		'version', $data->{'version'},
		'website', 'https://github.com/aullidolunar/scripts/tree/perl-percentage',
		'website-label', _('Visit website at github')
	);
}

sub on_button3_clicked {
	my ($button, $data) = @_;
	$data->{'window1'}->destroy;
}

sub Main {
	my ($manteiner, $p4ck4g3, $version) = @_;
	binmode (STDOUT, ":utf8");
	my $data_dir;
	if ($manteiner) {
		$data_dir = File::Spec->catdir ((abs_path =~ s/[^\/]*$//r), 'data');
	} else {
		$data_dir = File::Spec->catdir ('/usr/share', $p4ck4g3);
	} 
	my $localedir = File::Spec->catdir ($data_dir, 'locale');
	bind_textdomain_codeset ($p4ck4g3, "UTF-8");
	bindtextdomain ($p4ck4g3, $localedir);
	textdomain ($p4ck4g3);
	setlocale (LC_ALL, "");
	my $ui_file = File::Spec->catfile ($data_dir, $p4ck4g3 . '.builder');
	if (-f $ui_file) {
		print "$ui_file\n";
		my @objects_name = qw/window1 label3 combobox1 button1 entry1 entry2 entry3/;
		my %data = ('p4ck4g3' => $p4ck4g3, 'version' => $version);
		Gtk2->init;
		my $builder = Gtk2::Builder->new;
		$builder->add_from_file ($ui_file);
		$data{$_} = $builder->get_object ($_) foreach (@objects_name);
		$builder->connect_signals (\%data);
		undef ($builder);
		my $refArray = [
			['down.png', _('Choose the operation')],
			['plus.png', _('Increment')],
			['minus.png', _('Decrement')],
			['percentage.png', _('Percentage')],
		];
		my $model = $data{'combobox1'}->get_model;
		foreach my $row (@$refArray) {
			my $iter = $model->append;
			my $ pixbuf = Gtk2::Gdk::Pixbuf->new_from_file_at_size (File::Spec->catfile ($data_dir, $row->[0]), 16, 16);
			$model->set ($iter, 0, $pixbuf, 1, $row->[1]);
			undef ($pixbuf);
		}
		$data{'combobox1'}->set_active (0);
		$data{'window1'}->set_title ($p4ck4g3 . ' ' . $version);
		my $icon = File::Spec->catfile ($data_dir, 'main.png');
		$data{'window1'}->set_icon_from_file ($icon) if (-f $icon);
		$data{'window1'}->show_all;
		Gtk2->main;
		%data = ();
	} else {
		print _('No UI file found') . ': ' . $ui_file . "\n";
		return 1;
	}
	return 0;
}

exit Main (FALSE, ($0 =~ s/\.pl$//r), '1.0.4');
