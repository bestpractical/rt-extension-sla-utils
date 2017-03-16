use inc::Module::Install;

RTx     'RT-Extension-SLA-Utils';
license 'gplv2';
repository 'https://github.com/bestpractical/rt-extension-sla-utils';

requires_rt '4.0.0';

use Config;


my ($lp) = ($INC{'RT.pm'} =~ /^(.*)[\\\/]/);
my $lib_path = join( ' ', "$RT::LocalPath/lib", $lp );
my $secure_perl_path = $Config{perlpath};
if ($^O ne 'VMS') {
    $secure_perl_path .= $Config{_exe}
        unless $secure_perl_path =~ m/$Config{_exe}$/i;
}

substitute(
    {
        RT_LIB_PATH  => $lib_path,
        PERL         => $ENV{PERL} || $secure_perl_path,
    },
    {
        sufix => '.in'
    },
    qw(lib/RT/Extension/SLA/Utils/Test.pm),
);

sign;
WriteAll;
