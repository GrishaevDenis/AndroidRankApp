$('.ui.search')
	.search({
		apiSettings: {
			url: '/suggest?q={query}'
		},
		fields: {
			title: 'name',
			description: 'appid',
			price: 'ranks'
		},
		minCharacters: 2,
		maxResults: 10,
		onSelect: function(result, response) {
			show_result(result.appid)
		}
});

$('.clear_button button').click(function() {
	clear_result();
	$('#result').hide();
	$('.ui.search input').val('');
});

function show_result(appid) {
	$('#result').addClass('loading').show();
	$.get('/detail/'+appid, function(data) {
		$('#result').removeClass('loading');
		clear_result();
		if (data.error) {
			$('#result .item .header').text(data.error);
		} else {
			$('#result .item .image').html('<img src="'+data.icon+'" />');
			$('#result .item .header').text(data.name);
			$('#result .item .meta').html(data.artist_name);
			$('#result .item .description').html(data.short_text);
			$('#result .item .extra').html(data.app_info + data.rating_score + data.app_installs + data.rating_values);
			$('#result .item .extra2').html(data.country_rankings)
		}
	}).fail(function() {
		alert( "error" );
	});
}

function clear_result() {
	$('#result .item .content div').html('');
	$('#result .item .image').html('');
}
