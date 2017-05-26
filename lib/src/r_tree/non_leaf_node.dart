/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of r_tree;

class NonLeafNode extends Node {
  List<Node> _childNodes = [];

  NonLeafNode(int branchFactor) : super(branchFactor);

  @override
  List<Node> get children => _childNodes;

  @override
  Node createNewNode() {
    return new NonLeafNode(branchFactor);
  }

  @override
  Iterable<RTreeDatum> search(Rectangle searchRect, RTreeTest test) {
    List<RTreeDatum> overlappingLeafs = [];

    _childNodes.forEach((Node childNode) {
      if (childNode.overlaps(searchRect)) {
        overlappingLeafs.addAll(childNode.search(searchRect, test));
      }
    });

    return overlappingLeafs;
  }

  @override
  Node insert(RTreeDatum item) {
    include(item);

    Node bestNode = _getBestNodeForInsert(item);
    Node splitNode = bestNode.insert(item);

    if (splitNode != null) {
      addChild(splitNode);
    }

    return splitIfNecessary();
  }

  @override
  void remove(RTreeDatum item) {
    List<Node> childrenToRemove = [];

    _childNodes.forEach((Node childNode) {
      if (childNode.overlaps(item.rect)) {
        childNode.remove(item);

        if (childNode.size == 0) {
          childrenToRemove.add(childNode);
        }
      }
    });

    childrenToRemove.forEach((Node child) {
      removeChild(child);
    });
  }

  final Error nonNodeError =
      new ArgumentError("A non-leaf node can only have children of type Node");

  @override
  void addChild(RTreeContributor child) {
    if (child is Node) {
      super.addChild(child);
      child.parent = this;
    } else {
      throw nonNodeError;
    }
  }

  @override
  void removeChild(RTreeContributor child) {
    if (child is Node) {
      super.removeChild(child);
      child.parent = null;

      if (_childNodes.length == 0) {
        _convertToLeafNode();
      }
    } else {
      throw nonNodeError;
    }
  }

  @override
  void clearChildren() {
    _childNodes = [];
    _minimumBoundingRect = null;
  }

  Node _getBestNodeForInsert(RTreeDatum item) {
    num bestCost = double.INFINITY;
    num tentativeCost;
    Node bestNode;

    _childNodes.forEach((Node child) {
      tentativeCost = child.expansionCost(item);
      if (tentativeCost < bestCost) {
        bestCost = tentativeCost;
        bestNode = child;
      }
    });

    return bestNode;
  }

  _convertToLeafNode() {
    var nonLeafParent = parent as NonLeafNode;
    if (nonLeafParent == null) return;

    var newLeafNode = new LeafNode(this.branchFactor);
    newLeafNode.include(this);
    nonLeafParent.removeChild(this);
    nonLeafParent.addChild(newLeafNode);
  }
}
