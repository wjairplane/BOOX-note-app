import QtQuick

import xofm.libs.controls

/*
Let's the user decide on passphrase complexity.
If the customer wants to use a short, easy-to-brute-force passphrase he should be allowed to.
But in any case we should show a password strength indicator to nudge the user into making a more secure passphrase. I think three levels of complexity is enough. And I guess we don't have a way to look up common words, phrases or dictionary entries? If not, we can base the password strength calculation on password length, characters sets and number of unique characters and we could introduce a simple (naive) bits of entropy calculation:
Given
- Password length L
- Unique characters in password U
- Original Character Set OCS (lowercase = 26, uppercase = 26, numbers = 10, symbols ~= 10)
- Effective Character Set ECS = min (OCS, U^2)

Calculate Bits of Entropy E = L × log2​(ECS)

Examples:
Password: "abcabcabc",    L =  9, U =  3, OCS = 26, ECS = min(26,9)   =  9 => E =  8 x log2(9)  ~= 28 (weak)
Password: "abcdRT56",     L =  8, U =  8, OCS = 62, ECS = min(62,64)  = 62 => E =  8 x log2(62) ~= 47 (good)
Password: "azsxdcfvgbhn", L = 12, U = 12, OCS = 26, ECS = min(26,144) = 26 => E = 12 x log2(26) ~= 56 (strong)
Password: "RT8#TR8s)#fR", L = 12, U =  7, OCS = 72, ECS = min(72,49)  = 49 => E = 12 x log2(49) ~= 67 (strong)
*/

PasswordInputField {
    id: root

    property bool challengeSecurity: false
    property bool mismatch: false

    signal toggleMismatch()

    function calculateEntropy(str) {
        const n = str.length;

        // If the string is empty, the entropy is zero
        if (n === 0) {
            return {
                computed: "",
                length: 0,
                uniqueChars: 0,
                ocs: 0,
                ecs: 0,
                entropy: 0
            };
        }

        // Count the frequency of each character in the string
        const freqMap = {};
        for (let c of str) {
            freqMap[c] = (freqMap[c] || 0) + 1;
        }

        // Calculate the total number of unique characters
        const uniqueChars = Object.keys(freqMap).length;

        let ocs = 0;
        let small = false;
        let capital = false;
        let numbers = false;
        let special = false;
        for (let c of str) {
            if (!small && (c.charCodeAt(0) >= 97 && c.charCodeAt(0) <= 122)) {
                small = true;
                ocs += 26;
            } else if (!capital && (c.charCodeAt(0) >= 65 && c.charCodeAt(0) <= 90)) {
                capital = true;
                ocs += 26;
            } else if (!numbers && (c.charCodeAt(0) >= 48 && c.charCodeAt(0) <= 57)) {
                numbers = true;
                ocs += 10;
            } else if (!special && ( (c.charCodeAt(0) >= 33 && c.charCodeAt(0) <= 47) || (c.charCodeAt(0) >= 58 && c.charCodeAt(0) <= 64) || ((c.charCodeAt(0) >= 91 && c.charCodeAt(0) <= 96)) )) {
                special = true;
                ocs += 22;
            }
        }

        let ecs = Math.min(ocs, Math.pow(uniqueChars,2));
        let entropy = Math.round(str.length * Math.log2(ecs));

        return {
            computed: str,
            length: n,
            uniqueChars: uniqueChars,
            ocs: ocs,
            ecs: ecs,
            entropy: entropy
        };
    }

    titleText: qsTr("Password")
    labelVisible: label.length > 0
    validator: RegularExpressionValidator {
        regularExpression:/^.{8,}+$/
    }
    onShowWarning: {
        if (root.mismatch) {
            toggleMismatch();
            label = "";
            return;
        }

        if (text.length > 0) {
            label = "";

            if (root.challengeSecurity) {
                let str = qsTr("low");
                let entropy = calculateEntropy(text).entropy;

                if (text.length < 12 || entropy < 30) {
                    str = qsTr("low");
                } else if (text.length >= 12) {
                    if (entropy < 30) {
                        str = qsTr("low");
                    } else if (entropy > 50) {
                        str = qsTr("high");
                    } else {
                        str = qsTr("medium");
                    }
                } else if (text.length >= 16) {
                    if (entropy < 50) {
                        str = qsTr("medium");
                    } else {
                        str = qsTr("high");
                    }
                }
                label = qsTr("The password has %1 security").arg(str);
            }
        }
    }
}
