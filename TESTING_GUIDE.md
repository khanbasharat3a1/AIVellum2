# Testing Guide - Payment & Content Fixes

## Quick Test Scenarios

### 🔴 CRITICAL: Payment Security Tests

#### Test 1: Successful Payment
1. Open a locked premium prompt
2. Click "Pay Now" 
3. Complete payment successfully
4. **Expected:** 
   - ✅ Green success message appears
   - ✅ Prompt unlocks immediately
   - ✅ Content becomes visible
   - ✅ Screen auto-closes after 1.5s

#### Test 2: Canceled Payment
1. Open a locked premium prompt
2. Click "Pay Now"
3. Cancel the payment dialog
4. **Expected:**
   - ✅ Red error message: "Payment failed or was canceled"
   - ✅ Prompt stays LOCKED
   - ✅ Can try again
   - ✅ No content visible

#### Test 3: Failed Payment
1. Open a locked premium prompt
2. Click "Pay Now"
3. Use invalid payment method
4. **Expected:**
   - ✅ Red error message with details
   - ✅ Prompt stays LOCKED
   - ✅ 4 second message duration
   - ✅ No content visible

#### Test 4: Already Unlocked
1. Open an already unlocked prompt
2. Try to pay again
3. **Expected:**
   - ✅ Blue info message: "Already unlocked"
   - ✅ Screen closes immediately
   - ✅ No duplicate payment

#### Test 5: Subscription Payment
1. Click "Subscribe" button
2. Complete subscription payment
3. **Expected:**
   - ✅ Green success: "Subscription Activated"
   - ✅ ALL premium prompts unlock
   - ✅ Screen auto-closes
   - ✅ Can access all content

#### Test 6: Network Failure
1. Turn off internet
2. Try to make payment
3. **Expected:**
   - ✅ Error message appears
   - ✅ Prompt stays locked
   - ✅ Can retry when online

---

### 🟢 Content Display Tests

#### Test 7: Markdown Stripping
1. Find prompts with markdown (check JSON)
2. Open the prompt
3. **Expected:**
   - ✅ No `**bold**` markers visible
   - ✅ No `*italic*` markers visible
   - ✅ No `[links](url)` visible
   - ✅ No `# headers` visible
   - ✅ Clean, readable text only

#### Test 8: Copy Function
1. Open unlocked prompt with markdown
2. Click "Copy" button
3. Paste in text editor
4. **Expected:**
   - ✅ Copied text has no markup
   - ✅ Clean plain text
   - ✅ Success message shows

---

### 🔵 Subscription Tests

#### Test 9: Subscription Access
1. Subscribe successfully
2. Open any premium prompt
3. **Expected:**
   - ✅ All prompts show as unlocked
   - ✅ No payment required
   - ✅ Content immediately visible

#### Test 10: Subscription Expiry
1. Set subscription date to 31 days ago (manual DB edit)
2. Restart app
3. Open premium prompt
4. **Expected:**
   - ✅ Subscription expired
   - ✅ Prompts locked again
   - ✅ Payment required

---

### 🟡 Edge Case Tests

#### Test 11: Rapid Clicks
1. Open locked prompt
2. Click "Pay Now" multiple times rapidly
3. **Expected:**
   - ✅ Button disables during processing
   - ✅ Only one payment initiated
   - ✅ No duplicate charges

#### Test 12: App Restart After Payment
1. Make successful payment
2. Force close app
3. Restart app
4. Open the prompt
5. **Expected:**
   - ✅ Prompt still unlocked
   - ✅ Content visible
   - ✅ No re-payment needed

#### Test 13: Multiple Prompts
1. Unlock prompt A
2. Unlock prompt B
3. Restart app
4. **Expected:**
   - ✅ Both prompts unlocked
   - ✅ Other prompts still locked
   - ✅ State persisted

---

## 🐛 Bug Verification

### Original Bug: Unlock Without Payment
**How to verify it's fixed:**
1. Open locked prompt
2. Click "Pay Now"
3. Immediately cancel
4. **Check:** Prompt should stay LOCKED ✅

### Original Bug: No Payment Feedback
**How to verify it's fixed:**
1. Try any payment action
2. **Check:** Clear colored message appears ✅
3. **Check:** Message matches action result ✅

### Original Bug: Markdown Visible
**How to verify it's fixed:**
1. Open any prompt
2. **Check:** No `**`, `*`, `#`, `[]()` visible ✅
3. **Check:** Text is clean and readable ✅

---

## 📱 Platform-Specific Tests

### Android:
- [ ] Google Play billing works
- [ ] Subscription auto-renews
- [ ] Payment cancellation works
- [ ] Restore purchases works

### iOS:
- [ ] App Store billing works
- [ ] Subscription auto-renews
- [ ] Payment cancellation works
- [ ] Restore purchases works

---

## 🔍 Debug Mode Testing

### Enable Debug Logging:
Check console for these messages:
- `Purchase status: purchased for [product_id]`
- `Processing purchase: [product_id]`
- `Prompt [id] unlocked in database`
- `Subscription activated in database`

### Error Messages to Watch:
- `Purchase error: [details]`
- `Purchase canceled: [product_id]`
- `Store not available`

---

## ✅ Success Criteria

### Payment Security:
- ✅ No unlocking without successful payment
- ✅ Failed payments don't unlock content
- ✅ Canceled payments don't unlock content
- ✅ Pending payments show proper status

### User Feedback:
- ✅ Success = Green message
- ✅ Error = Red message
- ✅ Pending = Orange message
- ✅ Info = Blue message
- ✅ All messages clear and actionable

### Content Display:
- ✅ No markdown artifacts
- ✅ Clean, readable text
- ✅ Copy function works
- ✅ Share function works

### State Persistence:
- ✅ Unlocked prompts stay unlocked
- ✅ Subscription status persists
- ✅ Works after app restart
- ✅ Works after device restart

---

## 🚨 Critical Test Cases (Must Pass)

1. **MUST PASS:** Canceled payment = locked prompt
2. **MUST PASS:** Failed payment = locked prompt
3. **MUST PASS:** Successful payment = unlocked prompt
4. **MUST PASS:** No markdown visible in any prompt
5. **MUST PASS:** Subscription unlocks all prompts

---

## 📊 Test Results Template

```
Date: ___________
Tester: ___________
Platform: Android / iOS
Build: ___________

Payment Security Tests:
[ ] Test 1: Successful Payment - PASS/FAIL
[ ] Test 2: Canceled Payment - PASS/FAIL
[ ] Test 3: Failed Payment - PASS/FAIL
[ ] Test 4: Already Unlocked - PASS/FAIL
[ ] Test 5: Subscription Payment - PASS/FAIL
[ ] Test 6: Network Failure - PASS/FAIL

Content Display Tests:
[ ] Test 7: Markdown Stripping - PASS/FAIL
[ ] Test 8: Copy Function - PASS/FAIL

Subscription Tests:
[ ] Test 9: Subscription Access - PASS/FAIL
[ ] Test 10: Subscription Expiry - PASS/FAIL

Edge Case Tests:
[ ] Test 11: Rapid Clicks - PASS/FAIL
[ ] Test 12: App Restart - PASS/FAIL
[ ] Test 13: Multiple Prompts - PASS/FAIL

Critical Tests (All Must Pass):
[ ] Canceled payment = locked - PASS/FAIL
[ ] Failed payment = locked - PASS/FAIL
[ ] Successful payment = unlocked - PASS/FAIL
[ ] No markdown visible - PASS/FAIL
[ ] Subscription unlocks all - PASS/FAIL

Overall Status: PASS / FAIL
Notes: ___________
```

---

## 🎯 Priority Testing Order

1. **FIRST:** Test 2 (Canceled Payment) - Most critical
2. **SECOND:** Test 3 (Failed Payment) - Most critical
3. **THIRD:** Test 1 (Successful Payment) - Verify fix works
4. **FOURTH:** Test 7 (Markdown Stripping) - User experience
5. **FIFTH:** All other tests

---

## 💡 Tips for Testers

- Use test payment methods provided by Google/Apple
- Check console logs for debugging
- Test on both Android and iOS
- Test with different network conditions
- Test with different payment methods
- Document any unexpected behavior
- Take screenshots of error messages
- Note exact steps to reproduce issues

---

**Remember:** The most critical test is ensuring prompts DON'T unlock when payment fails or is canceled!
