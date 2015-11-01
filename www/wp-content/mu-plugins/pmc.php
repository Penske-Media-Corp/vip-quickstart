<?php

add_filter( 'jetpack_photon_skip_for_url', '__return_true' );

// remove emoji js support as it is causing major issue with site stability
add_action('wp_enqueue_scripts', function() {
	global $wp_scripts;
	wp_dequeue_script('emoji');
	wp_dequeue_script('twemoji');
});

add_action('wp_feed_options', function( $feed, $url ) {
	$feed->set_cache_duration( 12 * HOUR_IN_SECONDS );
}, 10, 2);

add_action( 'muplugins_loaded', function() {

	if ( WP_DEBUG ) {
		error_reporting( E_ALL );
	}
	
	$_SERVER['SERVER_NAME'] = parse_url( get_home_url(), PHP_URL_HOST );
	
	if ( defined('WP_CLI') && WP_CLI ) {
		// force display errors
		if ( !ini_get( 'display_errors' ) ) {
			ini_set( 'display_errors', '1' );
		}
		ob_implicit_flush(true);
		if( 0 < ob_get_level() ) {
			ob_flush();
			ob_end_flush();
		}
	}

} );

add_filter('validate_current_theme', '__return_false');
add_filter( 'pre_site_transient_update_core', '__return_null' );

if ( !isset ( $GLOBALS['pagenow'] ) ) {
	$GLOBALS['pagenow'] = '';
}

/**
 * Alter the timeout on cron requests from 0.01 to 0.5. Something about
 * the Vagrant and/or Ubuntu setup doesn't like these self requests 
 * happening so quickly.
 */
add_filter( 'cron_request', 'jf_cron_request', 10, 1 );
function jf_cron_request( $cron_request ) {
	$cron_request['args']['timeout'] = (float) 0.5;
	return $cron_request;
}

/*
 * This is the common endpoint for oauth redirect for
 * theme unit test plugin
 * https://github.com/Penske-Media-Corp/pmc-theme-unit-test
 * @since 2015-10-12 Archana Mandhare PMCVIP-62
 * For local - http://vip.local/redirectme/
 * For QA - http://qa.pmc.com/redirectme/
 */
add_action( 'init', function () {

	if ( false !== stripos( $_SERVER['REQUEST_URI'], '/redirectme' ) && ! empty( $_COOKIE['oauth_redirect'] ) ) {

		if ( ! empty( $_GET['code'] ) ) {

			$code           = sanitize_text_field( $_GET[ 'code' ] );
			$oauth_redirect = sanitize_text_field( $_COOKIE['oauth_redirect'] );
			$redirect_url   = $oauth_redirect . '&code=' . $code;
			wp_safe_redirect( $redirect_url );
			exit;

		}
	}

} );

//EOF
