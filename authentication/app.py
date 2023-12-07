import flask

from flask_oidc import OpenIDConnect

app = flask.Flask(__name__)
app.config.update({
    "TESTING": True,
    "DEBUG": True,
    "SECRET_KEY": "NOTverySECRET",
    "OIDC_CLIENT_SECRETS": "client_secrets.json",
    "OIDC_ID_TOKEN_COOKIE_SECURE": False,
    "OIDC_USER_INFO_ENABLED": True,
    "OIDC_OPENID_REALM": "flask-demo",
    "OIDC_SCOPES": ["openid", "email", "profile"],
    "OIDC_INTROSPECTION_AUTH_METHOD": "client_secret_post",
})

oidc = OpenIDConnect(app)

@app.route('/', methods=["GET"])
def index():
    auth_profile = flask.session.get("oidc_auth_profile", None)
    return flask.render_template("index.html", profile=auth_profile)

@app.route('/sign-in', methods=["GET"])
def sign_in():

    return flask.render_template("sign-in.html")

@app.route('/login', methods=["GET"])
@oidc.require_login
def login():
    return flask.redirect('/')

@app.route('/validate', methods=["POST"])
def validate():
    username = flask.request.form.get("username")
    password = flask.request.form.get("password")

    if username is None or password is None:
        return flask.redirect('/sign-in')
    
    if username == "admin" and password == "admin":
        flask.session["username"] = username
        flask.session["password"] = password
        return flask.redirect('/')
    
    return flask.redirect('/sign-in')

@app.route('/profile', methods=["GET"])
@oidc.require_login
def profile():
    auth_profile = flask.session.get("oidc_auth_profile", None)
    return flask.render_template("profile.html", profile=auth_profile)

@app.route('/logout')
def logout():
    oidc.logout()
    return flask.redirect('/')

@app.route('/register')
def register():
    return flask.redirect('/')

def main():
    app.run(host="localhost")

if __name__ == '__main__':
    main()