package Model::AndroidRank;
use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::Util qw(url_escape);
use JSON::XS;
use Carp;

has ua => sub {Mojo::UserAgent->new->max_redirects(3)};

sub suggest {
	my $self = shift;
	my $attrs = {@_};

	return {'error' => "Empty q"} unless $attrs->{'q'};

	my $json;

	eval {
		my $body = $self->ua->get('http://www.androidrank.org/searchjson?name_startsWith='.url_escape($attrs->{'q'}))->result->body;
		croak "Can't fetch url$/" unless $body;
		$body =~ s/^\(//; 
		$body =~ s/\)\;$//;
		eval {
			$json = decode_json($body);
		} or croak "Can't parse json$/";

		croak "Invalid json$/" unless ref $json && $json->{'geonames'};
	} or return {'error' => $@};

	return {'results' => $json->{'geonames'}};

}

sub get_app_detail {
	my $self = shift;
	my $attrs = {@_};

	return {'error' => "Empty ext_id"} unless $attrs->{'ext_id'};

	my $result = {};
	eval {

		my $dom = $self->ua->get('http://www.androidrank.org/details?id='.$attrs->{'ext_id'})->result->dom->at('div#content')->at('div');

		$result->{'name'} = $dom->children('div')->[0]->at('h1 span')->text;
		$result->{'icon'} = $dom->children('div')->[0]->at('img')->attr('src');
		$result->{'artist_id'} = $dom->children('div')->[0]->at('small a')->attr('href');
		$result->{'artist_id'} =~ s/\D//g;
		$result->{'artist_name'} = $dom->children('div')->[0]->at('small a')->text;
		$result->{'short_text'} = $dom->children('div')->[1]->content;
		$result->{'app_info'} = $dom->children('div')->[2]->children('div')->[0]->children('table.appstat')->[0]->to_string;
		$result->{'rating_score'} = $dom->children('div')->[2]->children('div')->[0]->children('table.appstat')->[1]->to_string;
		$result->{'app_installs'} = $dom->children('div')->[2]->children('div')->[1]->children('table.appstat')->[0]->to_string;
		$result->{'rating_values'} = $dom->children('div')->[2]->children('div')->[1]->children('table.appstat')->[1]->to_string;
		$result->{'country_rankings'} = $dom->children('div')->[3]->find('span')->map(attr => 'title')->join("<br />");
	} or return {'error' => "Error while parsing page"};

	foreach (keys %$result) {
		$result->{$_} =~ s[href=\"(.*?)\"][href=\"http://www.androidrank.org$1\" target=\"_blank\"]gi;
	}

	return $result;
}

1;
