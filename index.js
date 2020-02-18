const iframeHtml = ({ clientId, js }) => `
<html lang="en">
  <head>
    <meta name="google-signin-scope" content="profile email">
    <meta name="google-signin-client_id" content="${clientId}.apps.googleusercontent.com">
    <script src="https://apis.google.com/js/platform.js"></script>
	<style>
		body {
			margin: 0px;
			padding: 0px;
			border: 0px;
		}
	</style>
  </head>
  <body>
	<div class="g-signin2" data-onsuccess="onSignIn" data-theme="dark"></div>
    <script>
	${js}
    </script>
  </body>
</html>
`;
const signInJs = `
window.signIns = new EventTarget();
function onSignIn(googleUser) {
	signIns.dispatchEvent(new CustomEvent("signIn", { detail: googleUser }));
};
`;
const signOutJs = `
window.signOuts = new EventTarget();
document.body.onload = trySignOut;
function trySignOut() {
    if(gapi !== undefined && gapi.auth2.getAuthInstance().isSignedIn !== undefined) {
		gapi.auth2
			.getAuthInstance()
			.signOut()
			.then(() => signOuts.dispatchEvent(new CustomEvent("signOut")))
			.catch(e => setTimeout(trySignOut, 100));
	} else {
		setTimeout(trySignOut, 100);
	}
}
`;

class GoogleSignInButton extends HTMLElement {
	constructor() {
		super()
		this._clientId = null;
		this._profile = null;
		this._buttonKind = null;

		// Create a shadow root
		const shadow = this.attachShadow({mode: 'open'});

		// Create spans
		this.iframe = document.createElement('iframe');
		this.iframe.width = "120px";
		this.iframe.height = "36px";
		this.iframe.style = "border: 0px; padding: 0px; margins: 0px;";
		shadow.appendChild(this.iframe);
	}

	connectedCallback() {
		this.iframe.contentWindow.document.open();
		this.iframe.contentWindow.document.write(iframeHtml({
			clientId: this._clientId,
			js: signInJs,
		}));
		this.iframe.contentWindow.document.close();

		this.iframe.contentWindow.onload = () => {
			this.iframe.contentWindow.signIns.addEventListener("signIn", ({ detail: googleUser }) => {
				let profile = googleUser.getBasicProfile();
				this._profile = {
					id: profile.getId(),
					idToken: googleUser.getAuthResponse().id_token,
					name: profile.getName(),
					givenName: profile.getGivenName(),
					familyName: profile.getFamilyName(),
					imageUrl: profile.getImageUrl(),
					email: profile.getEmail(),
				};
				this.dispatchEvent(new CustomEvent("signIn"))
			});
		};
	}

	get profile() {
		return this._profile;
	}

	set clientId(id) {
		this._clientId = id;
	}
	get clientId() {
		return this._clientId;
	}
}
customElements.define("google-signin-button", GoogleSignInButton);

module.exports = {
	signOut: ({ port, clientId }) => {
		let iframe = document.createElement('iframe');
		iframe.width = "120px";
		iframe.height = "36px";
		iframe.style = "border: 0px; width: 0px; height: 0px; padding: 0px; margins: 0px;";
		document.body.appendChild(iframe);
		iframe.contentWindow.document.open();
		iframe.contentWindow.document.write(iframeHtml({
			clientId: clientId,
			js: signOutJs,
		}));
		iframe.contentWindow.document.close();
		tryListen();
		function tryListen() {
			if(iframe.contentWindow.signOuts !== undefined) {
				iframe.contentWindow.signOuts.addEventListener("signOut", () => port.send(clientId));
			} else {
				setTimeout(tryListen, 50)
			}
		};
	}
};
