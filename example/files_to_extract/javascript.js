// this was an extract from http://jsgettext.berlios.de/doc/html/Gettext.html

alert(_("some string"));
alert(gt.gettext("some string"));
alert(gt.gettext("some string"));
var myString = this._("this will get translated");
alert( _("text") );
alert( gt.gettext("Hello World!\n") );
var translated = Gettext.strargs( gt.gettext("Hello %1"), [full_name] );
Code: Gettext.strargs( gt.gettext("This is the %1 %2"), ["red", "ball"] );
printf( ngettext("One file deleted.\n",
                 "%d files deleted.\n",
                 count),
        count);
Gettext.strargs( gt.ngettext( "One file deleted.\n",
                              "%d files deleted.\n",
                              count), // argument to ngettext!
                 count);
alert( pgettext( "Verb: To View", "View" ) );
alert( pgettext( "Noun: A View", "View"  ) );
var count = 14;
Gettext.strargs( gt.ngettext('one banana', '%1 bananas', count), [count] );


// do not find _('error 1'); _("error 2");

/*
    do not find
    _('error 3');
    _("error 4");
*/

// Watch the position of parameters!
// The order of the chars d, c, n, p and x is fix but any combination is allowed.
_('text only');
// x (named placeholders): add that as last parameter
_x('text {foo}', {'foo' : 'bar'});
// n (plural): add the plural after text/singular
//             and the count to select singular/plural after plural
_nx('singular {foo}', 'plural {foo}', count, {'foo' : 'bar'});
// p (context): add the context before any text/singular/plural
_npx('context', 'singular {foo}', 'plural {foo}', count, {'foo' : 'bar'});
// d (text domain): add the domain as the first parameter
_dnpx('domain', 'context', 'singular {foo}', 'plural {foo}', count, {'foo' : 'bar'});// d (text domain)
// c (category): add the category as last parameter but before placeholders
_dcnpx('domain', 'context', 'singular {foo}', 'plural {foo}', count, 'context', {'foo' : 'bar'});
