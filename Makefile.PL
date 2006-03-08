use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'Sledge::Plugin::Email::Japanese',
    'VERSION_FROM' => 'lib/Sledge/Plugin/Email/Japanese.pm', # finds $VERSION
    'PREREQ_PM'    => {
        Test::More               => 0.32,
        MIME::Lite::TT::Japanese => 0.07,
        File::Slurp              => 9999.09,
        Class::Accessor          => 0.22,
    },
);
