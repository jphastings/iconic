$(document).ready(function() {
	$('#show_choose').click(function() {
		reset();
		$('#choose').slideDown()
	})
	
	$('#colors a').click(function() {
		var color = $(this).attr('href').substr(1);
		$('#objects a img').attr('class',color)
		
		if ($('#output .describe .object_1').hasClass('set') && $('#output .describe .color_1').hasClass('set')) {
			$('#output .describe .color_2').attr('class','color_2 color '+color).text(color)
			$('#chosen .object_2 img').attr('class','object_2 '+color)
			
			$('#output .describe .color_2').addClass('set')
		} else {
			$('#output .describe .color_1').attr('class','color_1 color '+color).text(color)
			$('#chosen .object_1 img').attr('class','object_1 '+color)
			
			$('#output .describe .color_1').addClass('set')
		}
		return false;
	})
	
	$('#objects a').click(function() {
		var object = $(this).attr('href').substr(1);
		
		if ($('#output .describe .color_2').hasClass('set')) {
			$('#output .describe .object_2').text(object)
			$('#chosen .object_2 img').attr('src','objects/'+object+'.png')
			
			$('#output .describe .object_2').addClass('set')
			
			var talk = $.makeArray($('#output .describe span').map(function(i,w) {return $(w).text()})).join(':');
			$.getJSON('/discover/'+talk).success(function(data) {
				$('#choose').slideUp()
				
				$('#results a').attr('href',data.uri)
				$('#results .title').text(data.title)
				$('#results .uri').text(data.uri)
				
				if (data.title == null) {
					getTitle(talk);
				} else {
					$('#results .title').removeClass('unknown')
					if (data.title == '-') {
						$('.results .title').fadeOut()
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
		} else {
			$('#output .describe .object_1').text(object)
			$('#chosen .object_1 img').attr('src','objects/'+object+'.png')
			
			$('#output .describe .object_1').addClass('set')
		}
		return false;
	})
	
	//$('[rel=tooltip]').tooltip()
})

function getTitle(talk) {
	$.getJSON(
		'/title/'+talk
	).success(function(data) {
		if (data == null || data == '-') {
			$('.results .title').fadeOut()
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
	$('#output .describe span').removeClass('set').text('')
	$('#chosen .object_1 img,#chosen .object_2 img').attr('src','img/unknown.png')
	$('#chosen img,#objects img').attr('class','nocolor')
	$('#results').fadeOut();
}