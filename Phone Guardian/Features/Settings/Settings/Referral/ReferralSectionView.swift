// ReferralSectionView.swift

import SwiftUI
import os

struct ReferralSectionView: View {
    @EnvironmentObject var iapManager: IAPManager
    @StateObject private var referralManager = ReferralManager()

    @State private var showShareSheet = false
    @State private var showReferralEntry = false
    @State private var showRedeemSheet = false
    @State private var showFeatureChoice = false

    @State private var enteredReferralCode: String = ""
    @State private var showInvalidCodeAlert = false
    @State private var showSelfReferralAlert = false
    @State private var showReferralSuccessAlert = false
    @State private var showNoAdsGranted = false

    private let logger = Logger(subsystem: "com.phoneguardian.referral", category: "ReferralSectionView")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Invite Your Friends")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text("""
                 Share your unique referral code with friends. When they download the app and enter your code, you earn rewards:
                 • 3 referrals: Temporarily unlock either Gold or Tools for 7 days.
                 • 5 referrals: Temporarily unlock the other add-on you don't have for 7 days.
                 • 7 referrals: Temporarily remove ads for 7 days.
                 """)
                .foregroundColor(.white)
                .font(.subheadline)

            HStack {
                Text("Your Code:")
                    .foregroundColor(.white)
                Spacer()
                Text(referralManager.userReferralData.referralCode)
                    .foregroundColor(.green)
                    .bold()
            }

            HStack {
                Text("Referrals:")
                    .foregroundColor(.white)
                Spacer()
                Text("\(referralManager.userReferralData.referralCount)")
                    .foregroundColor(.green)
                    .bold()
            }

            Button {
                showShareSheet = true
            } label: {
                Text("Share Your Code")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            Button {
                showReferralEntry = true
            } label: {
                Text("Referred By")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(8)
            }

            Button {
                showRedeemSheet = true
            } label: {
                Text("Redeem Rewards")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .alert(isPresented: $showInvalidCodeAlert) {
            Alert(title: Text("Invalid Code"), message: Text("Please enter a valid referral code."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showSelfReferralAlert) {
            Alert(title: Text("Error"), message: Text("You cannot enter your own referral code."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showReferralSuccessAlert) {
            Alert(title: Text("Success"), message: Text("You have successfully entered a referral code!"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showNoAdsGranted) {
            Alert(title: Text("No Ads Granted"), message: Text("You now have no ads for 7 days!"), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showShareSheet) {
            let shareText = "Download the Phone Guardian - Protect App and use my Invite code: \(referralManager.userReferralData.referralCode)"
            ReferralShareSheet(activityItems: [shareText])
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showReferralEntry) {
            VStack(spacing: 20) {
                Text("Enter Referral Code")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                TextField("Referral Code", text: $enteredReferralCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(.black)
                Button {
                    handleReferralCodeSubmission()
                } label: {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.black.opacity(0.9))
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showRedeemSheet) {
            VStack(spacing: 20) {
                Text("Your Referrals")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                if referralManager.userReferralData.referredUsers.isEmpty {
                    Text("You have no referrals yet.")
                        .foregroundColor(.white)
                } else {
                    List(referralManager.userReferralData.referredUsers, id: \.self) { user in
                        Text(user)
                            .foregroundColor(.white)
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                let count = referralManager.userReferralData.referralCount
                if count < 3 {
                    Text("You need at least 3 referrals to start unlocking temporary rewards.")
                        .foregroundColor(.white)
                        .padding()
                } else if count >= 7 {
                    Button {
                        referralManager.grantTemporaryFeature(.noAds)
                        showRedeemSheet = false
                        showNoAdsGranted = true
                    } label: {
                        Text("Temporarily Remove Ads (7 days)")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                } else if count >= 5 {
                    if iapManager.hasGoldSubscription || referralManager.isFeatureActive(.gold, hasPermanent: iapManager.hasGoldSubscription) {
                        Button {
                            referralManager.grantTemporaryFeature(.tools)
                            showRedeemSheet = false
                        } label: {
                            Text("Temporarily Unlock Tools (7 days)")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    } else if iapManager.hasToolsSubscription || referralManager.isFeatureActive(.tools, hasPermanent: iapManager.hasToolsSubscription) {
                        Button {
                            referralManager.grantTemporaryFeature(.gold)
                            showRedeemSheet = false
                        } label: {
                            Text("Temporarily Unlock Gold (7 days)")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    } else {
                        Button {
                            showRedeemSheet = false
                            showFeatureChoice = true
                        } label: {
                            Text("Temporarily Unlock Gold or Tools (7 days)")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    }
                } else if count >= 3 {
                    Button {
                        showRedeemSheet = false
                        showFeatureChoice = true
                    } label: {
                        Text("Temporarily Unlock Gold or Tools (7 days)")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.9))
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showFeatureChoice) {
            FeatureChoiceView { chosenFeature in
                if chosenFeature == .gold {
                    referralManager.grantTemporaryFeature(.gold)
                } else {
                    referralManager.grantTemporaryFeature(.tools)
                }
                showFeatureChoice = false
            }
            .ignoresSafeArea()
        }
    }

    private func handleReferralCodeSubmission() {
        let code = enteredReferralCode.trimmingCharacters(in: .whitespacesAndNewlines)
        referralManager.validateAndApplyReferral(code: code) { isValid, isSelfReferral, didSucceed in
            showReferralEntry = false
            if !isValid {
                self.showInvalidCodeAlert = true
            } else if isSelfReferral {
                self.showSelfReferralAlert = true
            } else if didSucceed {
                self.showReferralSuccessAlert = true
                referralManager.addReferredUser(code)
            } else {
                self.showInvalidCodeAlert = true
            }
        }
    }
}
