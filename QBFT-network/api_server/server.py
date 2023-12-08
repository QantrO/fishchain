import flask
import subprocess

app = flask.Flask(__name__)


@app.route('/')
def index():
    enode_address = get_enode_from_member()
    return flask.render_template('index.html', enode_address=enode_address)

@app.route('/add_node')
def add_node():
    # Add node to the network
    rc = subprocess.call(["sh", "../scripts/add_member_single_node.sh"])

    return flask.render_template('index.html')

@app.route('/add_node_all')
def add_node_all():
    # Add node to the network
    rc = subprocess.call(["sh", "../scripts/add_member_to_network.sh"])

    return flask.render_template('index.html')

def get_enode_from_member():
    rc = subprocess.run(["sh", "../scripts/get_enode.sh"], capture_output=True, text=True)
    return rc.stdout.strip()


def main():
    app.run(host="localhost", port=5000)

if __name__ == '__main__':
    main()