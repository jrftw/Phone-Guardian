// ReferralSectionView.swift

import SwiftUI
import os

struct ReferralSectionView: View {
    @EnvironmentObject var iapManager: IAPManager
    @StateObject private var referralManager = ReferralManager()
    @State private var showShareSheet = false
    @State private var referralLink: URL = URL(string: "https://example.com")!
    @State private var showFeatureChoice = false
    @State private var showNoAdsGranted = false
    @State private var showReferralEntry = false
    @State private var enteredReferralCode: String = ""
    @State private var showInvalidCodeAlert = false
    @State private var showSelfReferralAlert = false
    @State private var showReferralSuccessAlert = false
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
                generateReferralLink()
                showShareSheet = true
            } label: {
                Text("Share Your Code")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .fullScreenCover(isPresented: $showShareSheet) {
                ReferralShareSheet(activityItems: [referralLink])
                    .ignoresSafeArea()
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
            .alert(isPresented: $showInvalidCodeAlert) {
                Alert(title: Text("Invalid Code"), message: Text("Please enter a valid referral code."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showSelfReferralAlert) {
                Alert(title: Text("Error"), message: Text("You cannot enter your own referral code."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showReferralSuccessAlert) {
                Alert(title: Text("Success"), message: Text("You have successfully entered a referral code!"), dismissButton: .default(Text("OK")))
            }

            Button {
                redeemReferrals()
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
        .alert(isPresented: $showNoAdsGranted) {
            Alert(title: Text("No Ads Granted"), message: Text("You now have no ads for 7 days!"), dismissButton: .default(Text("OK")))
        }
    }

    private func generateReferralLink() {
        let code = referralManager.userReferralData.referralCode
        if let url = URL(string: "https://example.com/referral?code=\(code)") {
            referralLink = url
        }
    }

    private func redeemReferrals() {
        let count = referralManager.userReferralData.referralCount
        if count >= 7 {
            referralManager.grantTemporaryFeature(.noAds)
            showNoAdsGranted = true
        } else if count >= 5 {
            if iapManager.hasGoldSubscription || referralManager.isFeatureActive(.gold, hasPermanent: iapManager.hasGoldSubscription) {
                referralManager.grantTemporaryFeature(.tools)
            } else if iapManager.hasToolsSubscription || referralManager.isFeatureActive(.tools, hasPermanent: iapManager.hasToolsSubscription) {
                referralManager.grantTemporaryFeature(.gold)
            } else {
                showFeatureChoice = true
            }
        } else if count >= 3 {
            showFeatureChoice = true
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
            } else {
                // Code is valid format but not found in CloudKit
                self.showInvalidCodeAlert = true
            }
        }
    }
}
