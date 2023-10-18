const secp256k1 = require('secp256k1')
const keccak = require('keccak')
const { randomBytes } = require('crypto')
const fs = require('fs')
const Wallet = require('ethereumjs-wallet');
const yargs = require('yargs/yargs');

function generatePrivateKey() {
  let privKey
  do {
    privKey = randomBytes(32)
  } while (!secp256k1.privateKeyVerify(privKey))
  return privKey
}

function derivePublicKey(privKey) {
  // slice on the end to remove the compression prefix ie. uncompressed use 04 prefix & compressed use 02 or 03
  // we generate the address, which wont work with the compression prefix
  let pubKey = secp256k1.publicKeyCreate(privKey, false).slice(1)
  return Buffer.from(pubKey)
}

function deriveAddress(pubKey) {
  if (!Buffer.isBuffer(pubKey)) {
    console.log("ERROR - pubKey is not a buffer")
  }
  let keyHash = keccak('keccak256').update(pubKey).digest()
  return keyHash.slice(Math.max(keyHash.length - 20, 1))
}

function generateNodeData(path, name) {
  let privateKey = generatePrivateKey()
  let publicKey = derivePublicKey(privateKey)
  let address = deriveAddress(publicKey)
  console.log("keys created, writing to file...")
  fs.writeFileSync(`${path}/${name}/nodekey`, privateKey.toString('hex'));
  fs.writeFileSync(`${path}/${name}/nodekey.pub`, publicKey.toString('hex'));
  fs.writeFileSync(`${path}/${name}/address`, address.toString('hex'));
}

async function main(name, password) {

  const path = "../quorum_nodes_local/nodes";

  console.log(`${path}/${name}`)
  if (!fs.existsSync(`${path}/${name}`)) {
    fs.mkdirSync(`${path}/${name}`);
    console.log("directory created", name)
  }

  // generate nodekeys
  generateNodeData(path, name);

  // generate account
  const wallet = Wallet['default'].generate();
  const v3keystore = await wallet.toV3(password);
  console.log("account created, writing to file...")
  fs.writeFileSync(`${path}/${name}/accountKeystore`, JSON.stringify(v3keystore));
  fs.writeFileSync(`${path}/${name}/accountPrivateKey`, wallet.getPrivateKeyString());
  fs.writeFileSync(`${path}/${name}/accountPassword`, password);
  return {
    privateKey: wallet.getPrivateKeyString(),
    keystore: JSON.stringify(v3keystore),
    password: password
  }
}

try {
  const args = yargs(process.argv.slice(2)).options({
    name: { type: 'string', demandOption: false, default: '', describe: 'Name of the node' },
    password: { type: 'string', demandOption: false, default: '', describe: 'Password for the account' }
  }).argv;
  main(args.name, args.password);
} catch {
  console.error(e)
}

