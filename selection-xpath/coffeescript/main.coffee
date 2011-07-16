# Serialize and restore selection ranges
# Copyright (C) 2011 Fabio Mancinelli <fm@fabiomancinelli.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

serializeRange = (range) ->
        return "#{getXPath(range.startContainer)}|#{range.startOffset}|#{getXPath(range.endContainer)}|#{range.endOffset}"

# Build the XPath of a node
getXPath = (node) ->
        # Auxiliary function to get the index of a child node with respect to a parent.
        getChildIndex = (parent, node) ->
                index = 1
                for _, child of parent.childNodes
                        if child == node then return index
                        else if child.nodeName == node.nodeName then index++
                return -1

        # Auxiliary function for building the actual XPath expression.
        getXPathRecursive = (node, currentPath = "") ->
                if node.parentNode
                        switch node.nodeType
                                # In case of an ELEMENT node, use the actual node name
                                when 1
                                        currentPath = "/" + node.nodeName + "[" + getChildIndex(node.parentNode, node) + "]" + currentPath
                                # In case of a TEXT node, use text() as the node name
                                when 3, 4
                                        currentPath = "/text()[" + getChildIndex(node.parentNode, node) + "]" + currentPath
                        return getXPathRecursive(node.parentNode, currentPath)

                return currentPath

        # Build the actual XPath
        return getXPathRecursive(node)

# Used for displaying the grabbed selection in the original HTML
restoreSelection = () ->
        if window.startXPath
                range = document.createRange()
                range.setStart(document.evaluate(window.startXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue, window.startOffset)
                range.setEnd(document.evaluate(window.endXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue, window.endOffset)
                selection = window.getSelection()
                selection.removeAllRanges()
                selection.addRange(range)

##############################################################################
# UI interaction
##############################################################################

# Mouse up handler for UI interaction
mouseUpHandler = (event) ->
        modifier = event.ctrlKey || event.metaKey;
        if modifier
                selection =  window.getSelection()
                range = selection.getRangeAt(0)
                serialization = serializeRange(range)
                selection.removeAllRanges()

                [window.startXPath, window.startOffset, window.endXPath, window.endOffset] = serialization.split("|")

                messages = document.getElementById("messages")
                messages.innerHTML = "Selection grabbed:<br/>
                        &nbsp;Start XPath: <tt>#{window.startXPath}</tt><br/>
                        &nbsp;Start offset: <tt>#{window.startOffset}</tt><br/>
                        &nbsp;End XPath: <tt>#{window.endXPath}</tt><br/>
                        &nbsp;End offset: <tt>#{window.endOffset}</tt><br/>
                        <button onclick=\"restoreSelection()\">Restore selection</button>"

# Setup handler and global variables
window.addEventListener("mouseup", mouseUpHandler, false)
window.restoreSelection = restoreSelection
window.startXPath = null
window.startOffset = null
window.endXPath = null
window.endOffset = null
