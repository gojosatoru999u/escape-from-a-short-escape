import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import ts from 'typescript';
const source = await fs.readFile(new URL('../src/modules/escape-island/holderBonus.ts', import.meta.url), 'utf8');
const js = ts.transpileModule(source, { compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ESNext } }).outputText.replace('"@solana/web3.js"', JSON.stringify(import.meta.resolve('@solana/web3.js')));
const { bonusAccount, tokenBalance, formatBalance, readBalance, createHolderBonus, BONUS_MINT, BONUS_MIN_RAW } = await import('data:text/javascript;base64,'+Buffer.from(js).toString('base64'));
const owner = '8HA7Agw32MQMNXxmHKRNeHmn26yy38789jFcZZn6NSg5';
const account = amount => ({ owner: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA', executable: false, space: 165, data: { parsed: { type: 'account', info: { mint: BONUS_MINT, owner, tokenAmount: { amount, decimals: 6 } } } } });
test('exact threshold; associated account derivation; integer precision',()=> {
 assert.equal(tokenBalance({value:account('4999999999')},owner)>=BONUS_MIN_RAW,false);
 assert.equal(tokenBalance({value:account('5000000000')},owner)>=BONUS_MIN_RAW,true);
 assert.equal(bonusAccount(owner),'EF3AXRzuwMVUHucprfM5fLACxtqaTr1fvLbTcZXCMzgC');
 assert.equal(tokenBalance({value:null},owner),0n);
 assert.equal(tokenBalance({value:account('9007199254740993000')},owner),9007199254740993000n);
 assert.equal(formatBalance(4999999999n),'4 999,999999');
});
test('wrong mint, owner, decimals and malformed response rejected',()=>{
 const a=account('5000000000');a.data.parsed.info.mint='wrong';assert.throws(()=>tokenBalance({value:a},owner));
 assert.throws(()=>tokenBalance({value:account('5000000000')},'someoneelse'));
 const b=account('5000000000');b.data.parsed.info.tokenAmount.decimals=9;assert.throws(()=>tokenBalance({value:b},owner));
 const c=account('5000000000');c.owner='wrong';assert.throws(()=>tokenBalance({value:c},owner));
 assert.throws(()=>tokenBalance({},owner));
});
test('RPC failure is not zero; finalized read-only request',async()=>{
 await assert.rejects(readBalance(owner,async()=>({ok:false})),/RPC/);
 await assert.rejects(readBalance(owner,async()=>({ok:true,json:async()=>({error:{code:429}})})));
 await readBalance(owner,async(url,options)=>{const body=JSON.parse(options.body);assert.equal(body.method,'getAccountInfo');assert.equal(body.params[0],bonusAccount(owner));assert.equal(body.params[1].commitment,'finalized');return {ok:true,json:async()=>({result:{value:null}})};});
});
test('one tool per run; claim rechecks hold; reset, full inventory and intro',async()=>{
 const original=globalThis.fetch;let raw='5000000000';
 globalThis.fetch=async()=>({ok:true,json:async()=>({result:{value:account(raw)}})});
 try {
  let state={run:0,started:true,freeSlots:24};let grants=[];
  const bonus=createHolderBonus({blockchain:{getPlayAccess:async()=>({ok:true,data:{LinkedWallets:[{NetworkID:'solana',Address:owner}]}})}},()=>state,item=>grants.push(item));
  assert.equal((await bonus.check()).eligible,true);
  raw='4999999999';await assert.rejects(bonus.claim('Pickaxe'),/5 000/);assert.equal(grants.length,0);
  raw='5000000000';await bonus.claim('Club');await assert.rejects(bonus.claim('Sword'),/уже выбран/);assert.deepEqual(grants,['Club']);
  state={...state,run:1};assert.equal((await bonus.check()).chosen,undefined);await bonus.claim('Sword');assert.deepEqual(grants,['Club','Sword']);
  state={...state,run:2,freeSlots:0};await assert.rejects(bonus.claim('Pickaxe'),/место/);
  state={...state,freeSlots:24,started:false};await assert.rejects(bonus.claim('Pickaxe'),/вступление/);
 }finally{globalThis.fetch=original;}
});
test('no linked wallet: no balance or grant',async()=>{
 let grants=[];const bonus=createHolderBonus({blockchain:{getPlayAccess:async()=>({ok:true,data:{LinkedWallets:[]}})}},()=>({run:0,started:true,freeSlots:24}),item=>grants.push(item));
 const state=await bonus.check();assert.equal(state.balance,null);assert.equal(state.eligible,false);
 await assert.rejects(bonus.claim('Sword'));assert.equal(grants.length,0);
});
