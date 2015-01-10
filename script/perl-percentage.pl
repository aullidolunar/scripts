#!/usr/bin/perl

use warnings;
use utf8;
use strict;
use Gtk2;
use Glib qw/TRUE FALSE/;
use File::Spec;
use Cwd qw/abs_path/;
use Locale::gettext;
use POSIX;

# lapzas message: >

BEGIN {
	sub _ { gettext (@_); }
}

sub on_window1_destroy {
	my ($window, $data) = @_;
	Gtk2->main_quit;
}

sub on_button3_clicked {
	my ($button, $data) = @_;
	$data->{'window1'}->destroy;
}

sub Main {
	my ($manteiner, $package, $version) = @_;
	my $data_dir = File::Spec->catdir (($manteiner) ? (abs_path =~ s/[^\/]*$//r) : '/usr/share', ($manteiner) ? 'data' : $package);
	my $ui_file = File::Spec->catfile ($data_dir, $package . '.builder');
	if (-f $ui_file) {
		my @objects_name = qw/window1 combobox1/;
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
