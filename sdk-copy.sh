cd pancake-swap-sdk
npm run build
echo "cp -r ./dist ./local-pancakeswap-libs/sdk/"
cp -r ./dist ./local-pancakeswap-libs/sdk/
echo "cp -r ./local-pancakeswap-libs ../pancake-frontend/node_modules"
cp -r ./local-pancakeswap-libs ../pancake-frontend/node_modules
echo "copy finished"

