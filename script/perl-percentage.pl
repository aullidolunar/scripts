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

# lapzas message: >

BEGIN {
	sub _ { gettext (@_); }
}

sub toggle_button_ok {
	my ($button1, $entry1, $entry2, $combobox) = @_;
	my $index = $combobox->get_active;
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
}

sub on_window1_destroy {
	my ($window, $data) = @_;
	Gtk2->main_quit;
}

sub on_combobox1_changed {
	my ($combobox, $data) = @_;
	toggle_button_ok ($data->{'button1'}, $data->{'entry1'}, $data->{'entry2'}, $data->{'combobox1'});
}

sub on_any_entry_changed {
	my ($entry, $data) = @_;
	toggle_button_ok ($data->{'button1'}, $data->{'entry1'}, $data->{'entry2'}, $data->{'combobox1'});
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
}

sub on_button3_clicked {
	my ($button, $data) = @_;
	$data->{'window1'}->destroy;
}

sub Main {
	my ($manteiner, $package, $version) = @_;
	my $data_dir = File::Spec->catdir (($manteiner) ? (abs_path =~ s/[^\/]*$//r) : '/usr/share', ($manteiner) ? 'data' : $package);
	my $localedir = File::Spec->catdir ($data_dir, 'locale');
	bind_textdomain_codeset ($package, "UTF-8");
	bindtextdomain ($package, $localedir);
	textdomain ($package);
	setlocale (LC_ALL, "");
	my $ui_file = File::Spec->catfile ($data_dir, $package . '.builder');
	if (-f $ui_file) {
		my @objects_name = qw/window1 combobox1 button1 entry1 entry2 entry3/;
		my %data = ();
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
		$data{'window1'}->show_all;
		Gtk2->main;
		%data = ();
	} else {
		print _('No UI file found') . ': ' . $ui_file . "\n";
		return 1;
	}
	return 0;
}

exit Main (TRUE, ($0 =~ s/\.pl$//r), '1.0.1');
