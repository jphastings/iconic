$(document).ready(function() {
	$('#colors a').click(function() {
		var color = $(this).attr('href').substr(1);
		$('#objects a').attr('class','nocolor '+color)
		
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

			/*if ($('#output .describe .object_1').hasClass('set')) {
				$('#objects a img').attr('class','nocolor')
			}*/
		}
		return false;
	})
	
	$('#objects a').click(function() {
		var object = $(this).attr('href').substr(1);
		
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
		return false;
	})
	
	$('#text').bind('input',function(e) {
		var choose = $('#text').val().replace(/\s/g,'').replace(/[^a-z]/gi,'-');

		var a = $('#output .describe .color_1').hasClass('set');
		var b = $('#output .describe .object_1').hasClass('set');
		var c = $('#output .describe .color_2').hasClass('set');

		if (!a || b && !c) {
			$('#colors a:not([rel*='+choose+'])').addClass('semi');
			$('#colors a[rel*='+choose+']').removeClass('semi');
			
			switch($('#colors a[rel~='+choose+']').length) {
				case 1:
					$('#colors a[rel~='+choose+']').click()
					$('#text').val('')
					$('#colors a').removeClass('semi')
					// TODO: Show what was just typed
					break;
				case 0:
					$('#colors a:not([rel~='+choose+'])').addClass('semi');
					$('#colors a[rel*='+choose+']').removeClass('semi');
			}

			// Flags if there are no matches
			$('#text').toggleClass('nomatches',$('#colors a:not(.semi)').length == 0)
		} else {
			$('#objects a[rel*='+choose+']').show();
			$('#objects a:not([rel*='+choose+'])').hide();
			switch($('#objects a[rel~='+choose+']').show().length) {
				case 1:
					$('#objects a[rel~='+choose+']').click()
					$('#text').val('')
					$('#objects a').show()
					// TODO: Show what was just typed
					break
				case 0:
					$('#objects a:not([rel*='+choose+'])').hide();
			}

			// Flags if there are no matches
			$('#text').toggleClass('nomatches',$('#objects a:visible').length == 0)
		}
	})

	$('#demo').click(function(e){
		e.preventDefault();
		reset();
		$.each("greymanblackcherry".split(''),function(i,letter) {
			$('#text').queue(function() {
				$('#text').val($('#text').val() + letter).trigger(jQuery.Event('input'))
				$(this).dequeue();
			}).delay(Math.random()*500+200)
		})

	})
})

function completeInput() {
	var talk = $.makeArray($('#output .describe span').map(function(i,w) {return $(w).text()})).join(':');
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

function getTitle(talk) {
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
	$('#output .describe .color').removeClass('set').text('colour')
	$('#output .describe .object').removeClass('set').text('object')
	$('#chosen .object_1 img,#chosen .object_2 img').attr('src','img/unknown.png')
	$('#chosen img').attr('class','nocolor')
	$('#output .describe span').addClass('nocolor')
	$('#output .describe .color_1').attr('class','color color_1 nocolor')
	$('#output .describe .color_2').attr('class','color color_2 nocolor')
	$('#output .describe .object_1').attr('class','color object_1 nocolor')
	$('#output .describe .object_2').attr('class','color object_2 nocolor')
	$('#objects img').attr('class','nocolor')
	$('#results').fadeOut();
}