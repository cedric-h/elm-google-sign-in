import ElmGoogleSignIn from 'elm-google-sign-in/index.js';
import { Elm } from './src/Main.elm';

let googleSignOutComplete = new EventTarget();

let elm = document.createElement('div');
document.body.appendChild(elm);
let app = Elm.Main.init({
	node: elm,
	flags: googleSignOutComplete
});
app.ports.googleSignOut.subscribe(clientId => {
	ElmGoogleSignIn.signOut({
		port: app.ports.googleSignOutComplete,
		clientId: clientId,
	})
});
