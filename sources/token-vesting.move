//Context of token vesting:
// Alice has given work worth 1000 tokens (coin) named Mokshya 'MOK' which he has to pay to Bob on a different schedule as below.

// Jan 1, 200 MOK
// Jan 30, 300 MOK
// Feb 12, 400 MOK
// Feb 21, 100 MOK
// Bobs needs security that his payments will be made during these times. 
// Alice fears if he makes all the payments at the start then Bob might not complete the work.

// One solution is to find someone both of them trust to make the scheduled payment as required. 
// A much better solution will be to use a contract that will make these scheduled payments. This is the fundamental concept of token-vesting.

module token_vesting::vesting{
    use std::signer;    
    use aptos_framework::account;
    use std::vector;
    use aptos_framework::managed_coin;
    use aptos_framework::coin;
    use aptos_std::type_info;
    use aptos_std::simple_map::{Self, SimpleMap};
    struct VestingSchedule has key,store
    {
        sender: address,  
        receiver: address, 
        coin_type:address,
        release_times:vector<u64>,   //The times for unlocked
        release_amounts:vector<u64>, //The corresponding amount for getting unlocked
        total_amount:u64,            // Sum of all the release amount   
        resource_cap: account::SignerCapability, // Signer
        released_amount:u64,         //Sum of released amount
    }
    struct VestingCap has key
    {
        vestingMap: SimpleMap<vector<u8>,address>,
    }
    //errors code
    const ENO_INSUFFICIENT_FUND:u64=0;
    const ENO_NO_VESTING:u64=1;
    const ENO_SENDER_MISMATCH:u64=2;
    const ENO_RECEIVER_MISMATCH:u64=3;
    const ENO_WRONG_SENDER:u64=4;
    const ENO_WRONG_RECEIVER:u64=5;
    public entry fun create_vesting<CoinType>(
        account: &signer,
        receiver: address,
        release_amounts:vector<u64>,
        release_times:vector<u64>,
        total_amount:u64,
        seeds:vector<u8>
    ) acquires VestingCap{
        let account_adr=signer::address_of(account);
        let (vesting, vesting_cap)=account::create_resource_account(account, seeds);
        let vesting_address = signer::address_of(&vesting);
        if (!exists<VestingCap>(account_addr)) {
            move_to(account, VestingCap { vestingMap: simple_map::create() })
        };
        let maps = borrow_global_mut<VestingCap>(account_addr);
        simple_map::add(&mut maps.vestingMap, seeds,vesting_address);
        let vesting_signer_from_cap = account::create_signer_with_capability(&vesting_cap);
    }
}