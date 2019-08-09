requires 'perl', '5.024';
requires 'Amon2', '6.12';

requires 'DBD::mysql', '1.33';
requires 'HTML::FillInForm::Lite', '1.11';
requires 'JSON', '2.50';
requires 'Module::Functions', '2';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Router::Boom', '0.06';
requires 'Teng', '0.18';
requires 'Test::WWW::Mechanize::PSGI';
requires 'Text::Xslate', '2.0009';
requires 'Time::Piece', '1.20';
requires 'Module::Find';

requires 'Server::Starter';
requires 'Starlet', '0.20';

requires 'Log::Minimal';
requires 'Proclet';
requires 'Plack::Builder::Conditionals';
requires 'DBIx::QueryLog';
requires 'Plack::Middleware::HTTPExceptions';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Middleware::Log::Minimal';
requires 'Plack::Middleware::ServerStatus::Lite';
requires 'Plack::Middleware::AxsLog';
requires 'Devel::StackTrace::WithLexicals';

requires 'Cookie::Baker::XS';
requires 'HTTP::Parser::XS';
requires 'JSON::XS';
requires 'Time::TZOffset';
requires 'WWW::Form::UrlEncoded::XS';

requires 'strictures';

requires 'Text::Dice';
requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';
requires 'JSON::Types';
requires 'Cache::FileCache';
requires 'Path::Tiny';

requires 'Import::Into';

on configure => sub {
    requires 'Module::Build', '0.38';
    requires 'Module::CPANfile', '0.9010';
};

on test => sub {
    requires 'App::Prove::Plugin::MySQLPool';

    requires 'Test2';
    requires 'Test2::Suite';
    requires 'Unicode::GCString';

    requires 'String::Random';
    requires 'Test::WWW::Stub';
    requires 'Test::Time';
    requires 'Test::Time::At';
    requires 'Test::Mock::Guard';
};
