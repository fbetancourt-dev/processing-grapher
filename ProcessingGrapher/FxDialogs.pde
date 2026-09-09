/**
 * Helper Functions for Popup Dialogues using Java Swing
 * (Adapted for Processing 4 compatibility without JavaFX)
 *
 * @file  FxDialogs.pde
 */

import javax.swing.JOptionPane;
import javax.swing.JTextArea;
import javax.swing.JScrollPane;
import java.awt.Dimension;

/**
 * @class Java Swing Pop-up Dialogues (replaces legacy FxDialogs)
 */
public static class FxDialogs {

    public static void showInformation(String title, String message) {
        JOptionPane.showMessageDialog(null, message, title, JOptionPane.INFORMATION_MESSAGE);
    }

    public static void showWarning(String title, String message) {
        JOptionPane.showMessageDialog(null, message, title, JOptionPane.WARNING_MESSAGE);
    }

    public static void showError(String title, String message) {
        JOptionPane.showMessageDialog(null, message, title, JOptionPane.ERROR_MESSAGE);
    }

    public static void showException(String title, String message, Exception exception) {
        java.io.StringWriter sw = new java.io.StringWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
        exception.printStackTrace(pw);
        String exceptionText = sw.toString();

        JTextArea textArea = new JTextArea(exceptionText);
        textArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(textArea);
        scrollPane.setPreferredSize(new Dimension(500, 250));

        Object[] params = {message, scrollPane};
        JOptionPane.showMessageDialog(null, params, title, JOptionPane.ERROR_MESSAGE);
    }

    public static final String YES = "Yes";
    public static final String NO = "No";
    public static final String OK = "OK";
    public static final String CANCEL = "Cancel";

    public static String showConfirm(String title, String message, String... options) {
        if (options == null || options.length == 0) {
            options = new String[]{OK, CANCEL};
        }
        int result = JOptionPane.showOptionDialog(
            null,
            message,
            title,
            JOptionPane.DEFAULT_OPTION,
            JOptionPane.QUESTION_MESSAGE,
            null,
            options,
            options[0]
        );
        if (result >= 0 && result < options.length) {
            return options[result];
        } else {
            return CANCEL;
        }
    }

    public static String showTextInput(String title, String message, String defaultValue) {
        Object res = JOptionPane.showInputDialog(null, message, title, JOptionPane.QUESTION_MESSAGE, null, null, defaultValue);
        if (res != null) {
            return res.toString();
        } else {
            return null;
        }
    }
}