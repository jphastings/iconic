// TODO: undo colours / go back after success
var demo_string = 'redlorryyellowlorry';

$(document).ready(function() {
	$('#reset').click(reset);

	$('#colors a').click(function() {
		var color = $(this).attr('href').substr(1);
		$('#objects a').attr('class',color)
		$('#output').addClass('used')

		if ($('#output .describe .object_1').hasClass('set') && $('#output .describe .color_1').hasClass('set')) {
			// Target second object for colour change
			$('#output .describe .color_2').attr('class','color_2 color '+color).text(color)
			$('#chosen .object_2 img').attr('class','object_2 '+color)
			
			$('#output .describe .color_2').addClass('set')

			if ($('#output .describe .object_2').hasClass('set')) {
				completeInput();
			}
		} else {
			// Target first object for colour change
			$('#output .describe .color_1').attr('class','color_1 color '+color).text(color)
			$('#chosen .object_1 img').attr('class','object_1 '+color)
			
			$('#output .describe .color_1').addClass('set')

			if ($('#output .describe .object_1').hasClass('set')) {
				$('#objects a img').attr('class','nocolor')
			}
		}

		makeSuggestions();

		return false;
	})
	
	$('#objects a').click(function() {
		var object = $(this).attr('href').substr(1);
		$('#output').addClass('used')
		
		if ($('#output .describe .object_1').hasClass('set') && $('#output .describe .color_1').hasClass('set')) {
			$('#output .describe .object_2').text(object)
			$('#chosen .object_2 img').attr('src','objects/'+object+'.png')
			
			$('#output .describe .object_2').addClass('set')
			
			if ($('#output .describe .color_2').hasClass('set')) {
				completeInput();
			}
		} else {
			$('#output .describe .object_1').text(object)
			$('#chosen .object_1 img').attr('src','objects/'+object+'.png')
			$('#objects a').attr('class','nocolor')

			$('#output .describe .object_1').addClass('set')
		}

		makeSuggestions();

		return false;
	})
	
	$('#text').bind('input',function(e) {
		var choose = $('#text').val().replace(/\s/g,'').replace(/[^a-z]/gi,'-');

		var a = $('#output .describe .color_1').hasClass('set');
		var b = $('#output .describe .object_1').hasClass('set');
		var c = $('#output .describe .color_2').hasClass('set');

		var flyout = false;
		var fly_to = $('#output .describe .color_1').offset();

		if (!a || b && !c) {
			$('#colors a:not([rel*='+choose+'])').addClass('semi');
			$('#colors a[rel*='+choose+']').removeClass('semi');
			
			switch($('#colors a[rel~='+choose+']').length) {
				case 1:
					$('#colors a[rel~='+choose+']').click()
					$('#text').val('')
					$('#colors a').removeClass('semi')
					
					flyout = true;
					
					fly_to = a ? $('#output .describe .color_2').offset() : $('#output .describe .color_1').offset();

					break;
				case 0:
					$('#colors a:not([rel~='+choose+'])').addClass('semi');
					$('#colors a[rel*='+choose+']').removeClass('semi');
			}

			// Flags if there are no matches
			$('#text').toggleClass('nomatches',$('#colors a:not(.semi)').length == 0)
		} else {
			$('#objects a[rel*='+choose+']').removeClass('semi');
			$('#objects a:not([rel*='+choose+'])').addClass('semi');
			switch($('#objects a[rel~='+choose+']').length) {
				case 1:
					$('#objects a[rel~='+choose+']').click()
					$('#text').val('')
					$('#objects a').removeClass('semi')
					
					flyout = true;
					
					fly_to = b ? $('#output .describe .object_2').offset() : $('#output .describe .object_1').offset();

					break
				case 0:
					$('#objects a:not([rel*='+choose+'])').addClass('semi');
			}

			// Flags if there are no matches
			$('#text').toggleClass('nomatches',$('#objects a:not(.semi)').length == 0)
		}

		// Demonstrate what was typed
		if (flyout) {
			$('#typed').text(choose).show().animate({
				top:fly_to.top - $('#typed').offset().top,
				left:fly_to.left - $('#typed').offset().left,
				opacity:0
			},1000,'linear',function() {
				$(this).text('').css({
					'display':'none',
					'opacity':1.0,
					'top':0,
					'left':0
				})
			})
			
		}
	})

	$.getJSON('/suggest/x-x-x-x').success(function(data) {
		demo_string = data.join('')
	})

	$('#demo').click(function(e){
		e.preventDefault();

		reset();
		$.each(demo_string.split(''),function(i,letter) {
			$('#text').queue(function() {
				$('#text').val($('#text').val() + letter).trigger(jQuery.Event('input'))
				$(this).dequeue();
			}).delay(500)
		})

	})
})

function completeInput() {
	var talk = $.makeArray($('#output .describe span').map(function(i,w) {return $(w).text()})).join('-');
	$.getJSON('/discover/'+talk).success(function(data) {
		$('#colors,#objects').slideUp()
		
		$('#results a').attr('href',data.uri)
		$('#results .title').text(data.title)
		$('#results .uri').text(data.uri)
		
		if (data.title == null) {
			getTitle(talk);
		} else {
			$('#results .title').removeClass('unknown')
			if (data.title == '-') {
				$('.results .title').hide()
				$('.results .uri').toggleClass('major minor')
			}
		}
		
		$('#results').slideDown()
	}).error(function() {
		$('#response').addClass('error').text(':(').fadeIn().queue(function() {
			reset();
			
			$(this).dequeue();
		}).delay(1000).fadeOut();
	})
}

function makeSuggestions() {
	var talk = $.makeArray($('#output .describe span').map(function(i,w) {return $(w).text()})).join('-');

	$.getJSON('/suggest/'+talk).success(function(data) {
		for(section in data) {
			switch(section.split('_')[0]) {
				case 'object':
					$('#objects a:not([rel~="'+$.makeArray(data[section]).join('"],[rel~="')+'"])').css('opacity','0.1');
					$('#objects a[rel~="'+$.makeArray(data[section]).join('"],#objects a[rel~="')+'"]').css('opacity','1.0');
					break;
				case 'color':
					$('#colors a:not([rel~="'+$.makeArray(data[section]).join('"],[rel~="')+'"])').css('opacity','0.1');
					$('#colors a[rel~="'+$.makeArray(data[section]).join('"],#objects a[rel~="')+'"]').css('opacity','1.0');
					break;
			}
		}
	})
}

function getTitle(talk) {
	console.log(talk)
	$.getJSON(
		'/title/'+talk
	).success(function(data) {
		if (data == null || data == '-') {
			$('.results .title').hide()
			$('.results .uri').toggleClass('major minor')
		} else {
			$('.results .title').text(data).removeClass('unknown')
		}
	}).error(function() {
		$('.results .title').fadeOut()
		$('.results .uri').toggleClass('major minor')
	})
}

function reset() {
	$('#objects a,#colors,#objects').show().css('opacity','1.0');;
	$('#colors a').removeClass('semi').css('opacity','1.0');;
	$('#output .describe .color').removeClass('set').text('colour')
	$('#output .describe .object').removeClass('set').text('object')
	$('#chosen .object_1 img,#chosen .object_2 img').attr('src','img/unknown.png')
	$('#chosen img').attr('class','nocolor')
	$('#output .describe span').addClass('nocolor')
	$('#output .describe .color_1').attr('class','color color_1 nocolor')
	$('#output .describe .color_2').attr('class','color color_2 nocolor')
	$('#output .describe .object_1').attr('class','object object_1 nocolor')
	$('#output .describe .object_2').attr('class','object object_2 nocolor')
	$('#objects a').attr('class','nocolor')
	$('#results').fadeOut();
	$('.results .title').addClass('unknown').text('checking…')
	$('#output').removeClass('used')

	return false;
}