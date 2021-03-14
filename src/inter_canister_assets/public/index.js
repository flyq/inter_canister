import inter_canister from 'ic:canisters/inter_canister';

inter_canister.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
